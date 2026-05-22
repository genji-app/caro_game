import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart';
import 'package:sun_sports/core/services/providers/league_detail_provider.dart';
import 'package:sun_sports/core/services/providers/top_league_provider.dart';

/// Pattern tìm league FIFA World Cup 2026 trong danh sách league của Bóng đá.
/// Match không phân biệt hoa thường, tránh phụ thuộc cách BE đặt tên ('FIFA
/// WORLD CUP 2026', 'World Cup 2026', 'FIFA WC 2026'…).
const String _kFifaWorldCup2026NamePattern = 'WORLD CUP 2026';

/// Pre-fetch dữ liệu league của Bóng đá để khi user click "Cược ngay" trên
/// banner countdown, dữ liệu đã có sẵn trong cache.
///
/// Gọi trong `initState` của widget countdown. Vì [topLeagueEventsProvider] có
/// `ref.keepAlive()` bên trong, kết quả fetch sẽ được giữ trong cả vòng đời
/// app sau lần đầu — không gọi lại API ở các lần navigate sau.
///
/// Lưu ý hiệu năng: đây là call API có thể "lãng phí" nếu user không click
/// vào banner. Trade-off để đổi lấy điều hướng tức thì khi user thực sự click.
void prewarmFifaWorldCup2026Data(WidgetRef ref) {
  // ignore: unused_result, đây là fire-and-forget để kích hoạt cache.
  ref.read(topLeagueEventsProvider(SportType.soccer.id));
}

/// Điều hướng đến trang league detail của FIFA World Cup 2026.
///
/// Hàm bất đồng bộ. Hành vi theo trạng thái cache của
/// [topLeagueEventsProvider] tại thời điểm click:
/// - Đã có data → resolve tức thì (~micro-task), navigate ngay.
/// - Đang fetch (prewarm chạy nhưng chưa xong) → đợi cùng request in-flight
///   rồi navigate. Không phát sinh API call mới.
/// - Chưa từng được đọc → trigger fetch và đợi response trước khi navigate.
///
/// Nhờ `keepAlive` trong provider, mọi lần click tiếp theo (trong cùng phiên
/// app) sẽ luôn rơi vào nhánh "đã có data" — instant.
///
/// Chỉ fallback `goToSport()` khi:
/// - API thực sự lỗi (network/timeout/server).
/// - Response không chứa league nào khớp [_kFifaWorldCup2026NamePattern].
///
/// Lưu ý gọi từ widget: vì await không có loading UI, nếu fetch chậm user sẽ
/// thấy banner "đứng" vài trăm ms đến 1–2s trước khi route đổi. Đa số case
/// (prewarm chạy trước trong initState) sẽ không cảm nhận được delay.
Future<void> navigateToFifaWorldCup2026(WidgetRef ref) async {
  final mainContent = ref.read(mainContentProvider.notifier);

  final List<LeagueModelV2> leagues;
  try {
    // .future luôn trả Future:
    // - Cache hit: Future đã completed → micro-task resolve.
    // - In-flight: cùng Future đang chạy.
    // - Chưa start: kích hoạt build + trả Future của lần fetch này.
    leagues = await ref.read(
      topLeagueEventsProvider(SportType.soccer.id).future,
    );
  } catch (_) {
    // API lỗi (network/timeout/5xx). Cho user vào trang Sport chung
    // để vẫn còn đường đi tiếp.
    mainContent.goToSport();
    return;
  }

  final fifaWc = leagues
      .where(
        (league) =>
            league.displayName.toUpperCase().contains(
              _kFifaWorldCup2026NamePattern,
            ),
      )
      .firstOrNull;

  if (fifaWc == null) {
    // Response hợp lệ nhưng BE chưa pin World Cup 2026 hoặc đặt tên khác.
    mainContent.goToSport();
    return;
  }

  ref.read(selectedLeagueInfoProvider.notifier).state = SelectedLeagueInfo(
    sportId: fifaWc.sportId,
    leagueId: fifaWc.leagueId,
    leagueName: fifaWc.displayName,
    leagueLogo: fifaWc.leagueLogo,
  );
  mainContent.goToLeagueDetail();
}
