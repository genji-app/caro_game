import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sun_sports/core/providers/main_content_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/game/new_tab_opener/new_tab_opener.dart';
import 'package:sun_sports/features/home/domain/ncc_sportbook.dart';
import 'package:sun_sports/features/home/domain/ncc_tab_opener.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

/// Section "Top nhà cung cấp" bản mobile — 3 card NCC (KSport / Saba / BTI).
/// Design Figma node 6002:38850. Cùng cấu trúc/logic với [HomeDesktopNccSection],
/// chỉ khác kích thước & tỉ lệ card (mobile dùng card dọc 148.6x200).
class HomeMobileNccSection extends ConsumerWidget {
  const HomeMobileNccSection({super.key});

  // `final` (không phải `const`): AppImages.* là getter nên list không const được.
  static final List<_NccProvider> _providers = [
    _NccProvider(
      type: NccProvider.ksport,
      name: 'KSPORT',
      image: AppImages.imageBannerKSport,
      // TODO(ncc-logo): thay logoText bằng asset logo NCC khi có.
      logoText: 'K+',
      gradientTop: const Color(0xFFCD2828),
      gradientBottom: const Color(0xFFA71B1B),
      borderColor: const Color(0xFFFF2424),
      overlayColor: const Color(0xFF6C1006),
      logoPath: AppIcons.iconKSport,
    ),
    _NccProvider(
      type: NccProvider.saba,
      name: 'SABA SPORT',
      image: AppImages.imageBannerSaba,
      logoText: 'SB',
      gradientTop: const Color(0xFFB78300),
      gradientBottom: const Color(0xFF985800),
      borderColor: const Color(0xFFFFB700),
      overlayColor: const Color(0xFF985800),
      logoPath: AppIcons.iconSaba,
    ),
    _NccProvider(
      type: NccProvider.bti,
      name: 'BTI SPORT',
      image: AppImages.imageBannerBTI,
      logoText: 'BTI',
      gradientTop: const Color(0xFF0070C6),
      gradientBottom: const Color(0xFF00439D),
      borderColor: const Color(0xFF008DFF),
      overlayColor: const Color(0xFF00439D),
      logoPath: AppIcons.iconBTI,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.12),
          offset: const Offset(0, 0.5),
          blurRadius: 0.5,
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Top nhà cung cấp'),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gap xen giữa các Expanded → cả 3 card chia đều bề rộng.
              for (int i = 0; i < _providers.length; i++) ...[
                if (i > 0) const Gap(8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        _handleTap(ref, context, _providers[i].type),
                    child: _buildProviderCard(_providers[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  /// Xử lý tap card NCC.
  /// - KSport: điều hướng nội bộ sang Sport screen.
  /// - Saba/BTI: gọi API lấy launch URL rồi mở (web: tab mới, native: trình
  ///   duyệt ngoài).
  Future<void> _handleTap(
    WidgetRef ref,
    BuildContext context,
    NccProvider type,
  ) async {
    if (!type.isSportbookLaunch) {
      ref.read(mainContentProvider.notifier).goToSport();
      return;
    }

    // Đang chạy NCC khác → bỏ qua (tránh mở tab trắng thừa).
    if (ref.read(nccLaunchProvider) != null) return;

    // Web: mở sẵn tab trắng NGAY trong user-gesture để tránh popup-blocker.
    final pendingTab = kIsWeb ? openPendingTab() : null;

    final result = await ref.read(nccLaunchProvider.notifier).launch(type);

    switch (result) {
      case NccLaunchSuccess(:final url):
        if (kIsWeb) {
          if (pendingTab != null) {
            pendingTab.navigate(url);
          } else {
            // Tab trắng bị chặn sẵn → thử mở trực tiếp.
            openNewTab(url);
          }
        } else {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      case NccLaunchFailure(:final message):
        pendingTab?.close();
        if (context.mounted) {
          AppToast.showError(context, message: message);
        }
      case NccLaunchCancelled():
        pendingTab?.close();
    }
  }

  Widget _buildSectionHeader(String title) => Container(
    height: 44,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: AppTextStyles.labelMedium(color: AppColorStyles.contentPrimary),
    ),
  );

  // Kích thước card gốc theo Figma mobile (148.6x200) — mọi số đo bên trong
  // scale theo bề rộng card thực tế để co giãn đồng đều thay vì fix cứng.
  static const double _designCardWidth = 148.6;
  static const double _cardAspectRatio = 148.6 / 200;

  // Tỉ lệ chiều cao lớp gradient phủ dưới so với card (126/200 theo Figma).
  static const double _overlayHeightFactor = 126 / 200;

  Widget _buildProviderCard(_NccProvider provider) => LayoutBuilder(
    builder: (context, constraints) {
      // Hệ số scale = bề rộng card thực tế / bề rộng thiết kế.
      final scale = constraints.maxWidth / _designCardWidth;
      return AspectRatio(
        aspectRatio: _cardAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: provider.borderColor, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [provider.gradientTop, provider.gradientBottom],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Ảnh cầu thủ (nền trong suốt) — phóng nhẹ, canh đầu lên trên.
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.15,
                    alignment: Alignment.topCenter,
                    child: ImageHelper.load(
                      path: provider.image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                // Lớp gradient mờ dần ở dưới + logo + tên NCC.
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: _overlayHeightFactor,
                      child: Container(
                        width: constraints.maxWidth,
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          16 * scale,
                          16 * scale,
                          24 * scale,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              provider.overlayColor.withOpacity(0),
                              provider.overlayColor,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildLogoPlaceholder(provider.logoPath, scale),
                            Gap(12 * scale),
                            Text(
                              provider.name,
                              style: AppTextStyles.headingXSmall(
                                color: const Color(0xFFFFFEF5),
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16 * scale,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlay loading khi NCC đang fetch launch URL — chỉ card
                // đang loading rebuild (Consumer + select), không cả section.
                Positioned.fill(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final isLoading = ref.watch(
                        nccLaunchProvider.select((p) => p == provider.type),
                      );
                      if (!isLoading) return const SizedBox.shrink();
                      return ColoredBox(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFFFFFEF5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  /// Logo NCC tạm thời (badge tròn). Sẽ thay bằng asset logo thật sau.
  // TODO(ncc-logo): thay bằng ImageHelper.load(path: <logo asset>).
  Widget _buildLogoPlaceholder(String logoPath, double scale) => Container(
    width: 44 * scale,
    height: 44 * scale,
    alignment: Alignment.center,
    child: ImageHelper.load(
      path: logoPath,
      width: 44 * scale,
      height: 44 * scale,
      fit: BoxFit.contain,
    ),
  );
}

class _NccProvider {
  const _NccProvider({
    required this.type,
    required this.name,
    required this.image,
    required this.logoText,
    required this.gradientTop,
    required this.gradientBottom,
    required this.borderColor,
    required this.overlayColor,
    required this.logoPath,
  });

  /// Xác định hành vi khi tap (điều hướng nội bộ vs launch sportbook).
  final NccProvider type;
  final String name;
  final String image;
  final String logoText;
  final Color gradientTop;
  final Color gradientBottom;
  final Color borderColor;
  final Color overlayColor;
  final String logoPath;
}
