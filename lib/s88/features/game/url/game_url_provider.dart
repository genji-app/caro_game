import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Status of game URL loading
enum GameUrlStatus {
  /// Initial state, no request made yet
  initial,

  /// Loading game URL from API
  loading,

  /// Game URL loaded successfully
  success,

  /// Error occurred while loading
  error,
}

/// State for a single game URL request
class GameUrlState {
  const GameUrlState({
    this.status = GameUrlStatus.initial,
    this.url,
    this.error,
  });

  final GameUrlStatus status;
  final String? url;
  final String? error;

  // Helper getters for status checks
  bool get isError => status == GameUrlStatus.error;
  bool get isInitial => status == GameUrlStatus.initial;
  bool get isLoading => status == GameUrlStatus.loading;
  bool get isSuccess => status == GameUrlStatus.success;

  GameUrlState copyWith({GameUrlStatus? status, String? url, String? error}) {
    return GameUrlState(
      status: status ?? this.status,
      url: url ?? this.url,
      error: error,
    );
  }
}

/// Notifier for managing game URL state
class GameUrlNotifier extends StateNotifier<GameUrlState> with LoggerMixin {
  final GameRepository _repository;

  // Store last params for retry
  String? _lastProviderId;
  String? _lastProductId;
  String? _lastGameCode;
  String? _lastLang;
  bool? _lastIsMobileLogin;

  GameUrlNotifier({required GameRepository repository})
    : _repository = repository,
      super(const GameUrlState()) {
    logInfo('GameUrlNotifier initialized');
  }

  Future<String?> getGameUrl({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) async {
    logInfo(
      'Fetching game URL: '
      'provider=$providerId, '
      'product=$productId, '
      'game=$gameCode',
    );

    // Store params for retry
    _lastProviderId = providerId;
    _lastProductId = productId;
    _lastGameCode = gameCode;
    _lastLang = lang;
    _lastIsMobileLogin = isMobileLogin;

    state = state.copyWith(status: GameUrlStatus.loading, error: null);

    try {
      final url = await _repository.getGameUrl(
        providerId: providerId,
        productId: productId,
        gameCode: gameCode,
        lang: lang,
        isMobileLogin: isMobileLogin,
      );

      logInfo('Game URL fetched successfully');
      logDebug('URL: $url');

      state = state.copyWith(url: url, status: GameUrlStatus.success);
      return url;
    } on GetGameUrlFailure catch (e) {
      logError('Failed to get game URL', e, StackTrace.current);
      state = state.copyWith(
        status: GameUrlStatus.error,
        error: e.errorMessage,
      );
      return null;
    } catch (e, stackTrace) {
      logError('Unexpected error while getting game URL', e, stackTrace);
      state = state.copyWith(
        status: GameUrlStatus.error,
        error: 'Unexpected error: $e',
      );
      return null;
    }
  }

  /// Retry the last request
  Future<String?> retry() async {
    if (_lastProviderId == null ||
        _lastProductId == null ||
        _lastGameCode == null) {
      logWarning('Retry failed: No previous request to retry');
      state = state.copyWith(
        status: GameUrlStatus.error,
        error: 'No previous request to retry',
      );
      return null;
    }

    logInfo(
      'Retrying game URL request: '
      'provider=$_lastProviderId, '
      'product=$_lastProductId, '
      'game=$_lastGameCode',
    );

    return getGameUrl(
      providerId: _lastProviderId!,
      productId: _lastProductId!,
      gameCode: _lastGameCode!,
      lang: _lastLang,
      isMobileLogin: _lastIsMobileLogin,
    );
  }

  /// Clear state
  void clear() {
    logInfo('Clearing game URL state');
    state = const GameUrlState();
    _lastProviderId = null;
    _lastProductId = null;
    _lastGameCode = null;
    _lastLang = null;
    _lastIsMobileLogin = null;
    logDebug('Game URL state cleared');
  }
}

/// Provider for game URL state
final gameUrlProvider = StateNotifierProvider<GameUrlNotifier, GameUrlState>((
  ref,
) {
  final repository = ref.watch(gameRepositoryProvider);
  return GameUrlNotifier(repository: repository);
});
