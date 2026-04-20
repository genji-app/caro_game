import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart';

import '../sport_api_service.dart';
import 'sport_switch_state.dart';
import 'sport_switching_config.dart';

/// Service xử lý việc chuyển sport với Triple Protection:
/// 1. Debounce - Đợi user ngừng tap
/// 2. Version Check - Bỏ qua response cũ
/// 3. Cancel Token - Hủy request đang pending
class SportSwitchingService {
  SportSwitchingService({
    required SportSocketClient client,
    required ExampleApiService apiService,
    SportSwitchingConfig? config,
  })  : _client = client,
        _apiService = apiService,
        _config = config ?? SportSwitchingConfig.defaultConfig;

  // ============================================
  // Dependencies
  // ============================================
  final SportSocketClient _client;
  final ExampleApiService _apiService;
  final SportSwitchingConfig _config;

  // ============================================
  // State Management
  // ============================================
  SportSwitchState _currentState = const SportSwitchState();
  final _stateController = StreamController<SportSwitchState>.broadcast();

  /// Stream với initial value emit cho new subscribers
  Stream<SportSwitchState> get stateStream async* {
    yield _currentState;
    yield* _stateController.stream;
  }

  /// Current state
  SportSwitchState get currentState => _currentState;

  /// Current sport ID
  int get currentSportId => _currentState.currentSportId;

  /// Đang switching?
  bool get isSwitching => _currentState.isSwitching;

  // ============================================
  // Triple Protection Components
  // ============================================

  /// 1. DEBOUNCE - Timer để đợi user ngừng tap
  Timer? _debounceTimer;

  /// 2. VERSION CHECK - Mỗi request có version riêng
  int _requestVersion = 0;

  /// 3. CANCEL TOKEN - Hủy HTTP request đang pending
  CancelToken? _cancelToken;

  /// Track old sport for error recovery
  int _oldSportId = 1;

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Initialize service với sport
  Future<void> initialize(int sportId) async {
    _log('Initialize with sportId: $sportId');

    _currentState = SportSwitchState.initial(sportId: sportId);
    _stateController.add(_currentState);
  }

  /// Chuyển sport (Public API - có debounce)
  void changeSport(int newSportId) {
    // Validate
    if (!SportIds.isValid(newSportId)) {
      _log('Invalid sportId: $newSportId', isError: true);
      return;
    }

    // Skip nếu đã ở sport này và không đang switch
    if (newSportId == currentSportId && !isSwitching) {
      _log('Already on sport $newSportId, skipping');
      return;
    }

    _log('Change sport requested: $currentSportId → $newSportId');

    // ═══════════════════════════════════════════
    // STEP 1-3: Prepare for debounce
    // ═══════════════════════════════════════════

    // Save old sport for error recovery
    _oldSportId = _currentState.currentSportId;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Update state immediately (cho UI feedback)
    _updateState(_currentState.toPreparing(newSportId));

    if (_config.enableDebounce) {
      // Đợi debounce
      _debounceTimer = Timer(_config.debounceDuration, () {
        _log('Debounce complete, executing switch to $newSportId');
        _executeSwitch(newSportId);
      });
    } else {
      // Execute ngay (cho testing)
      _executeSwitch(newSportId);
    }
  }

  /// Force switch ngay lập tức (bypass debounce)
  Future<void> forceSwitchSport(int sportId) async {
    _debounceTimer?.cancel();
    await _executeSwitch(sportId);
  }

  /// Retry lần switch thất bại gần nhất
  Future<void> retry() async {
    if (!_currentState.hasError) return;

    final targetSport =
        _currentState.targetSportId ?? _currentState.currentSportId;
    _log('Retrying switch to sport $targetSport');
    await _executeSwitch(targetSport);
  }

  /// Reset về idle state
  void reset() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Reset called');
    _updateState(_currentState.toIdle());
  }

  /// Dispose service
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Service disposed');
    _stateController.close();
    _log('Service disposed');
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  Future<void> _executeSwitch(int sportId) async {
    // ═══════════════════════════════════════════
    // STEP 6: VERSION CHECK - increment version
    // ═══════════════════════════════════════════
    final version = ++_requestVersion;
    _log('Execute switch: sport=$sportId, version=$version');

    // ═══════════════════════════════════════════
    // STEP 7-8: CANCEL TOKEN - cancel old, create new
    // ═══════════════════════════════════════════
    if (_config.enableCancelToken) {
      _cancelToken?.cancel('New switch initiated');
      _cancelToken = CancelToken();
    }

    // STEP 9: Update state to SWITCHING
    _updateState(_currentState.toSwitching(version));

    try {
      // ─────────────────────────────────────────
      // STEP 10: Unsubscribe all sports
      // ─────────────────────────────────────────
      _unsubscribeAllSports();

      // ─────────────────────────────────────────
      // STEP 11: Clear data store
      // ─────────────────────────────────────────
      _client.dataStore.clear();
      _log('Data store cleared');

      // STEP 12: Update state to LOADING
      _updateState(_currentState.toLoading());

      // ─────────────────────────────────────────
      // STEP 13: Call API to fetch new data (AWAIT!)
      // ─────────────────────────────────────────
      await _apiService.fetchAndPopulateStore(
        sportId: sportId,
        store: _client.dataStore,
        fetchHot: true,
        cancelToken: _cancelToken,
      );

      // ─────────────────────────────────────────
      // STEP 14: VERSION CHECK trước khi tiếp tục
      // ─────────────────────────────────────────
      if (_config.enableVersionCheck && version != _requestVersion) {
        _log(
            '⚠️ Stale response ignored: version=$version, current=$_requestVersion');
        return; // Silently ignore
      }

      // ─────────────────────────────────────────
      // STEP 15: Subscribe sport mới
      // ─────────────────────────────────────────
      _subscribeSport(sportId);

      // ─────────────────────────────────────────
      // STEP 16: Update AutoRefreshManager sportId
      // ─────────────────────────────────────────
      // NOTE: Không gọi _client.changeSport() vì nó sẽ duplicate work:
      // - Unsubscribe lại (đã làm)
      // - Clear data (đã làm)
      // - Fetch API lại (duplicate!)
      // - Subscribe lại (đã làm)
      // Chỉ cần update AutoRefreshManager sportId
      _client.autoRefreshManager?.updateSportId(sportId);
      _log('AutoRefreshManager sportId updated to $sportId');

      // Emit changes để UI nhận update
      _client.dataStore.emitBatchChanges();

      // ─────────────────────────────────────────
      // STEP 17: Update state to READY
      // ─────────────────────────────────────────
      _updateState(_currentState.toReady(sportId));
      _log('✅ Switch complete: sport=$sportId');
    } on DioException catch (e) {
      await _handleDioError(e, version, sportId);
    } catch (e, stackTrace) {
      await _handleGenericError(e, stackTrace, version, sportId);
    }
  }

  /// Handle Dio errors
  Future<void> _handleDioError(DioException e, int version, int sportId) async {
    // Ignore cancelled requests
    if (e.type == DioExceptionType.cancel) {
      _log('Request cancelled for sport $sportId');
      return;
    }

    // Check version before showing error
    if (_config.enableVersionCheck && version != _requestVersion) {
      _log('Ignoring error for stale request: version=$version');
      return;
    }

    final errorMessage = _getDioErrorMessage(e);
    _log('❌ API Error: $errorMessage', isError: true);

    // Error recovery: re-subscribe old sport
    _subscribeSport(_oldSportId);

    _updateState(_currentState.toError(errorMessage));
  }

  /// Handle generic errors
  Future<void> _handleGenericError(
    Object e,
    StackTrace stackTrace,
    int version,
    int sportId,
  ) async {
    // Check version before showing error
    if (_config.enableVersionCheck && version != _requestVersion) {
      _log('Ignoring error for stale request: version=$version');
      return;
    }

    _log('❌ Error: $e\n$stackTrace', isError: true);

    // Error recovery: re-subscribe old sport
    _subscribeSport(_oldSportId);

    _updateState(_currentState.toError('Failed to load. Please try again.'));
  }

  /// Get user-friendly error message
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again.';
      default:
        return 'Network error. Please try again.';
    }
  }

  /// Unsubscribe all sports
  void _unsubscribeAllSports() {
    _log('Unsubscribing all sports');
    for (final id in SportIds.all) {
      _client.unsubscribeSport(id);
    }
  }

  /// Subscribe to a sport
  void _subscribeSport(int sportId) {
    _log('Subscribing to sport $sportId');
    _client.subscribeSport(sportId);
  }

  /// Update state và emit
  void _updateState(SportSwitchState newState) {
    if (_currentState == newState) return;

    _log('State: ${_currentState.status} → ${newState.status}');
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Logging
  void _log(String message, {bool isError = false}) {
    if (!_config.logEnabled) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = isError ? '❌' : '🔄';
    debugPrint('[$timestamp] $prefix [SportSwitch] $message');
  }
}
