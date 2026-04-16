import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';

import 'sport_switch_state.dart';
import 'sport_switching_config.dart';

/// Service xử lý việc chuyển sport với Triple Protection:
/// 1. Debounce - Đợi user ngừng tap
/// 2. Version Check - Bỏ qua response cũ
/// 3. Cancel Token - Hủy request đang pending
///
/// Uses [SportSocketAdapter] which handles:
/// - Unsubscribe from current sport
/// - Clear current sport data
/// - Fetch new sport data from API
/// - Subscribe to new sport
class SportSwitchingService {
  SportSwitchingService({
    required SportSocketAdapter adapter,
    required SportStorage storage,
    SportSwitchingConfig? config,
  }) : _adapter = adapter,
       _storage = storage,
       _config = config ?? SportSwitchingConfig.defaultConfig {
    _setupReconnectHandler();
  }

  // ============================================
  // Dependencies
  // ============================================
  final SportSocketAdapter _adapter;
  final SportStorage _storage;
  final SportSwitchingConfig _config;

  // ============================================
  // State Management
  // ============================================
  SportSwitchState _currentState = const SportSwitchState();
  final _stateController = StreamController<SportSwitchState>.broadcast();
  StreamSubscription<socket.ConnectionStateEvent>? _reconnectSubscription;

  /// Stream với initial value emit cho new subscribers
  ///
  /// ✅ FIX: Return broadcast stream directly instead of async* generator
  /// async* creates NEW stream instance on each call → listener leak
  /// broadcast stream can be listened to multiple times safely
  Stream<SportSwitchState> get stateStream => _stateController.stream;

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

  /// Initialize service với sport đã lưu
  Future<void> initialize() async {
    await _storage.init();
    final savedSportId = await _storage.getSportId();
    _log('Initialize with sportId: $savedSportId');

    // ✅ Emit initial state immediately for early subscribers
    _currentState = SportSwitchState.initial(sportId: savedSportId);
    _stateController.add(_currentState);

    // Luôn fetch leagues khi initialize để đảm bảo data mới nhất
    await _executeSwitch(savedSportId, isInitial: true);
  }

  /// Chuyển sport (Public API - có debounce)
  ///
  /// ```dart
  /// service.changeSport(SportId.basketball.value);
  /// ```
  void changeSport(int newSportId) {
    // Validate
    if (!SportTypeValidation.isValidId(newSportId)) {
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
    _reconnectSubscription?.cancel();
    _stateController.close();
    _log('Service disposed');
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  Future<void> _executeSwitch(int sportId, {bool isInitial = false}) async {
    // ═══════════════════════════════════════════
    // VERSION CHECK - increment version
    // ═══════════════════════════════════════════
    final version = ++_requestVersion;
    _log('Execute switch: sport=$sportId, version=$version');

    // ═══════════════════════════════════════════
    // CANCEL TOKEN - cancel old, create new
    // ═══════════════════════════════════════════
    if (_config.enableCancelToken) {
      _cancelToken?.cancel('New switch initiated');
      _cancelToken = CancelToken();
    }

    // Update state to SWITCHING
    _updateState(_currentState.toSwitching(version));

    try {
      // Update state to LOADING
      _updateState(_currentState.toLoading());

      // ─────────────────────────────────────────
      // Call adapter.changeSport() which handles:
      // - Unsubscribe from current sport
      // - Clear current sport data
      // - Fetch new sport data from API
      // - Subscribe to new sport
      // ─────────────────────────────────────────
      await _adapter.changeSport(sportId);

      // ─────────────────────────────────────────
      // VERSION CHECK trước khi tiếp tục
      // ─────────────────────────────────────────
      if (_config.enableVersionCheck && version != _requestVersion) {
        _log(
          '⚠️ Stale response ignored: version=$version, current=$_requestVersion',
        );
        return; // Silently ignore
      }

      // Update state to READY
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

    // Error recovery: restore old sportId in storage
    // (adapter clears data but doesn't restore on failure)
    await _storage.saveSportId(_oldSportId);

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

    // Error recovery: restore old sportId in storage
    // (adapter clears data but doesn't restore on failure)
    await _storage.saveSportId(_oldSportId);

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

  /// Setup reconnect handler
  ///
  /// Adapter tự động reconnect và re-subscribe, nhưng service cần
  /// biết để update state nếu cần.
  void _setupReconnectHandler() {
    _reconnectSubscription = _adapter.onConnectionChanged.listen((event) {
      if (event.currentState == socket.ConnectionState.connected) {
        final sportId = _currentState.currentSportId;
        _log('WebSocket reconnected for sport $sportId');
        // Adapter tự động re-subscribe, không cần manual subscribe
      }
    });
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
