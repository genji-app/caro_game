import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/network/sb_config_loader.dart';
import 'package:co_caro_flame/s88/features/download_app/data/models/download_app_config.dart';

/// URL config download app — plain JSON trên GitHub.
const String _kDownloadAppConfigUrl =
    'https://raw.githack.com/genji-app/config_download/main/config_download_app.json';

/// State của remote config.
///
/// - [config] = null khi chưa load xong (lần đầu).
/// - [isLoading] = true khi đang fetch.
/// - [error] != null khi load thất bại (UI có thể fallback sang giá trị rỗng).
class DownloadAppConfigState {
  const DownloadAppConfigState({
    this.config,
    this.isLoading = false,
    this.error,
  });

  final DownloadAppConfig? config;
  final bool isLoading;
  final String? error;

  bool get hasConfig => config != null;

  DownloadAppConfigState copyWith({
    DownloadAppConfig? config,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return DownloadAppConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const Object _sentinel = Object();
}

/// Notifier load config từ remote URL ở background.
///
/// `SbConfigLoader.getConfigJson` đã handle:
/// - GET với cache-busting query param
/// - Parse plain JSON (không base64 decode)
/// - Timeout 10s
///
/// Notifier chỉ cần chuyển `Map<String, dynamic>` thành [DownloadAppConfig]
/// qua `fromJson`. Errors được store vào state, KHÔNG throw lên trên — UI
/// sẽ tự fallback sang giá trị rỗng (ẩn các widget tương ứng).
class DownloadAppConfigNotifier extends StateNotifier<DownloadAppConfigState> {
  DownloadAppConfigNotifier() : super(const DownloadAppConfigState());

  /// Fetch config từ remote. Idempotent: nếu đang loading hoặc đã có config
  /// thì không fetch lại (trừ khi gọi [refresh]).
  Future<void> load() async {
    if (state.isLoading || state.hasConfig) return;
    await _fetch();
  }

  /// Force refresh: bỏ qua cache state, fetch lại từ network.
  Future<void> refresh() async {
    if (state.isLoading) return;
    await _fetch();
  }

  Future<void> _fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await SbConfigLoader.getConfigJson(_kDownloadAppConfigUrl);
      final config = DownloadAppConfig.fromJson(json);
      state = DownloadAppConfigState(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider toàn cục cho download app config.
///
/// Load 1 lần ở app startup (xem `app.dart::_initApp`):
/// ```dart
/// unawaited(ref.read(downloadAppConfigProvider.notifier).load());
/// ```
///
/// UI consume:
/// ```dart
/// final config = ref.watch(downloadAppConfigProvider).config;
/// ```
final downloadAppConfigProvider =
    StateNotifierProvider<DownloadAppConfigNotifier, DownloadAppConfigState>(
      (ref) => DownloadAppConfigNotifier(),
    );
