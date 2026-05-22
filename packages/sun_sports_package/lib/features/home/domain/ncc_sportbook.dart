import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:sun_sports/features/game/game_providers.dart';

/// 3 nhà cung cấp (NCC) hiển thị ở section "Top nhà cung cấp" trên Home desktop.
enum NccProvider {
  /// KSport — chỉ điều hướng nội bộ sang Sport screen, không gọi API.
  ksport(apiProviderId: null, apiGameCode: null),

  saba(apiProviderId: 'saba', apiGameCode: 'saba'),

  // ⚠️ KHÔNG sửa "typo" gameCode này — server đang dùng đúng chuỗi 'SporstBook'.
  bti(apiProviderId: 'bti', apiGameCode: 'SporstBook');

  const NccProvider({required this.apiProviderId, required this.apiGameCode});

  /// `providerId` trong API `/providers/games`. `null` nghĩa là NCC này không
  /// dùng API (KSport điều hướng nội bộ).
  final String? apiProviderId;

  /// `gameCode` cố định dùng để gọi get-url.
  final String? apiGameCode;

  /// `true` nếu tap NCC này phải gọi API lấy launch URL (Saba/BTI).
  bool get isSportbookLaunch => apiProviderId != null;
}

/// Lỗi nghiệp vụ khi không lấy được launch URL của NCC.
class NccLaunchException implements Exception {
  const NccLaunchException(this.message);

  final String message;

  @override
  String toString() => 'NccLaunchException: $message';
}

/// Kết quả của một lần launch NCC sportbook.
sealed class NccLaunchResult {
  const NccLaunchResult();
}

/// Lấy URL thành công.
class NccLaunchSuccess extends NccLaunchResult {
  const NccLaunchSuccess(this.url);

  final String url;
}

/// Thất bại — [message] để hiển thị toast.
class NccLaunchFailure extends NccLaunchResult {
  const NccLaunchFailure(this.message);

  final String message;
}

/// Bị huỷ — đang có NCC khác chạy, hoặc request đã bị thay thế.
class NccLaunchCancelled extends NccLaunchResult {
  const NccLaunchCancelled();
}

/// Lấy launch URL của NCC sportbook (Saba/BTI) qua 2 API:
/// `GET /providers/games` → tìm provider + game → `POST /providers/get-url`.
class NccSportbookLauncher {
  const NccSportbookLauncher(this._client);

  final gac.GameApiClient _client;

  /// Trả về launch URL cho [provider]. Throw [NccLaunchException] nếu không
  /// tìm thấy NCC/game tương ứng.
  Future<String> fetchLaunchUrl(NccProvider provider) async {
    final providerId = provider.apiProviderId;
    final gameCode = provider.apiGameCode;
    if (providerId == null || gameCode == null) {
      throw NccLaunchException('NCC ${provider.name} không hỗ trợ launch URL');
    }

    // 1. Lấy danh sách provider/games, tìm đúng providerId.
    final providers = await _client.getGames();
    gac.ProviderGames? matchedProvider;
    for (final p in providers) {
      if (p.providerId.toLowerCase().trim() == providerId) {
        matchedProvider = p;
        break;
      }
    }
    if (matchedProvider == null) {
      throw const NccLaunchException('NCC chưa sẵn sàng');
    }

    // 2. Tìm game theo gameCode cố định.
    gac.Game? matchedGame;
    for (final g in matchedProvider.gameList) {
      if (g.gameCode == gameCode) {
        matchedGame = g;
        break;
      }
    }
    if (matchedGame == null) {
      throw const NccLaunchException('NCC chưa sẵn sàng');
    }

    // 3. Lấy launch URL (lang/isMobileLogin theo curl mẫu).
    return _client.getGameUrl(
      gac.GetGameUrlRequest(
        providerId: matchedProvider.providerId,
        productId: matchedGame.productId,
        gameCode: matchedGame.gameCode,
        lang: 'vi',
        isMobileLogin: false,
      ),
    );
  }
}

/// Quản lý trạng thái loading khi launch NCC sportbook.
/// State = NCC đang fetch URL (`null` = rảnh).
class NccLaunchNotifier extends StateNotifier<NccProvider?> {
  NccLaunchNotifier(this._launcher) : super(null);

  final NccSportbookLauncher _launcher;

  /// Tăng mỗi lần [launch] — dùng để bỏ qua kết quả của request đã cũ.
  int _requestId = 0;

  /// Gọi API lấy launch URL cho [provider].
  ///
  /// Trả [NccLaunchCancelled] nếu đang có NCC khác chạy hoặc request bị thay
  /// thế bởi lần [launch] mới hơn.
  Future<NccLaunchResult> launch(NccProvider provider) async {
    if (state != null) return const NccLaunchCancelled();

    final id = ++_requestId;
    state = provider;
    try {
      final url = await _launcher.fetchLaunchUrl(provider);
      if (id != _requestId) return const NccLaunchCancelled();
      return NccLaunchSuccess(url);
    } on NccLaunchException catch (e) {
      return NccLaunchFailure(e.message);
    } catch (_) {
      return const NccLaunchFailure('Không thể mở nhà cung cấp');
    } finally {
      if (id == _requestId) state = null;
    }
  }
}

/// Service lấy launch URL — phụ thuộc [gameApiClientProvider] (đã wire token).
final nccSportbookLauncherProvider = Provider<NccSportbookLauncher>(
  (ref) => NccSportbookLauncher(ref.watch(gameApiClientProvider)),
);

/// Trạng thái loading khi launch NCC sportbook. Keep-alive (action toàn app):
/// notifier sống suốt vòng đời app nên không bị dispose giữa flow.
final nccLaunchProvider =
    StateNotifierProvider<NccLaunchNotifier, NccProvider?>(
      (ref) => NccLaunchNotifier(ref.watch(nccSportbookLauncherProvider)),
    );
