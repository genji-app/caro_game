import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:sun_sports/features/download_app/data/models/download_app_config.dart';
import 'package:sun_sports/features/download_app/presentation/providers/download_app_config_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

const double _dialogWidth = 402;

class DialogDownloadApp extends StatelessWidget {
  const DialogDownloadApp({super.key, this.isBottomSheet = false});

  final bool isBottomSheet;

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _DownloadAppContent(isBottomSheet: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _DownloadAppContent(isBottomSheet: false);
  }
}

class _DownloadAppContent extends ConsumerWidget {
  const _DownloadAppContent({required this.isBottomSheet});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final config = ref.watch(downloadAppConfigProvider).config;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    final container = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: MediaQuery.of(context).size.width <= 733 ? null : _dialogWidth,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.gray700, width: 1),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DownloadHeader(onClose: () => Navigator.of(context).pop()),
              // Scrollable body để chứa description dài + store buttons
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AppDescriptionSection(config: config),
                      const SizedBox(height: 24),
                      _DownloadAppSection(
                        config: config,
                        onAndroidStore: () =>
                            _launchUrl(context, config?.urlAndroidStore ?? ''),
                        onIosStore: () =>
                            _launchUrl(context, config?.urlIosStore ?? ''),
                        onApk: () => _launchUrl(
                          context,
                          config?.urlFileAndroidApk ?? '',
                        ),
                      ),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isMobile) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Container(alignment: Alignment.bottomCenter, child: container),
      );
    }

    return Container(alignment: Alignment.bottomCenter, child: container);
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// Header: close button (Figma 9054-72793)
class _DownloadHeader extends StatelessWidget {
  const _DownloadHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Ứng dụng chính thức',
              style: AppTextStyles.headingXXXSmall(
                context: context,
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.gray400, size: 24),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mô tả ứng dụng (Figma 9054-67913): app icon + title + description.
/// Dùng config từ remote, fallback về placeholder khi config chưa load xong.
///
/// Description support expand/collapse:
/// - Default: hiển thị tối đa [_collapsedMaxLines] dòng + ellipsis nếu vượt.
/// - Click "Xem thêm" → hiển thị full text.
/// - Click "Thu gọn" → quay về 4 dòng.
/// - Toggle button CHỈ xuất hiện khi text thật sự vượt 4 dòng (đo bằng TextPainter).
class _AppDescriptionSection extends StatefulWidget {
  const _AppDescriptionSection({required this.config});

  final DownloadAppConfig? config;

  @override
  State<_AppDescriptionSection> createState() => _AppDescriptionSectionState();
}

class _AppDescriptionSectionState extends State<_AppDescriptionSection> {
  static const int _collapsedMaxLines = 2;

  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final appName = config?.appName ?? '';
    final type = config?.type ?? '';
    final fullDescription = config?.fullDescription ?? '';
    final iconUrl = config?.urlIconApp ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon: dùng url_icon_app từ config nếu có, fallback iconAppFake.
              ImageHelper.load(
                path: iconUrl.isNotEmpty ? iconUrl : AppImages.iconAppFake,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
                borderRadius: 12,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appName,
                      style: AppTextStyles.headingSmall(
                        context: context,
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                    if (type.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: AppTextStyles.paragraphSmall(
                          context: context,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (fullDescription.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ExpandableDescription(
              text: fullDescription,
              maxLines: _collapsedMaxLines,
              expanded: _expanded,
              onToggle: _toggleExpanded,
            ),
          ],
        ],
      ),
    );
  }
}

/// Description text với toggle "Xem thêm / Thu gọn".
///
/// Đo overflow bằng [TextPainter] với [maxLines] cố định + width khả dụng từ
/// [LayoutBuilder]. Toggle button chỉ hiển thị khi `didExceedMaxLines == true`.
class _ExpandableDescription extends StatelessWidget {
  const _ExpandableDescription({
    required this.text,
    required this.maxLines,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final int maxLines;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = AppTextStyles.paragraphSmall(
      context: context,
      color: AppColorStyles.contentSecondary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Đo text với maxLines = collapsed limit để biết có overflow không.
        // Result không phụ thuộc `expanded` → toggle visibility ổn định khi
        // chuyển state.
        final tp = TextPainter(
          text: TextSpan(text: text, style: descriptionStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: descriptionStyle,
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    expanded ? 'Thu gọn' : 'Xem thêm',
                    style: AppTextStyles.paragraphSmall(
                      context: context,
                      color: AppColors.yellow300,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ContentForApp extends StatelessWidget {
  final String description;

  const _ContentForApp({required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ImageHelper.load(
          path: AppIcons.iconCheckYellow,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: AppTextStyles.paragraphSmall(
              context: context,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Section download buttons. Mỗi button (Android Play Store / APK direct / iOS)
/// chỉ hiển thị khi URL tương ứng KHÔNG empty + match với platform browser.
///
/// Browser rule:
/// - Android browser → ẩn iOS (Android Play Store + APK nếu có).
/// - iOS browser → ẩn Android Play Store + APK.
/// - Desktop / native → hiển thị mọi button có URL.
class _DownloadAppSection extends StatelessWidget {
  const _DownloadAppSection({
    required this.config,
    required this.onAndroidStore,
    required this.onIosStore,
    required this.onApk,
  });

  final DownloadAppConfig? config;
  final VoidCallback onAndroidStore;
  final VoidCallback onIosStore;
  final VoidCallback onApk;

  @override
  Widget build(BuildContext context) {
    final iosUrl = config?.urlIosStore ?? '';
    final androidUrl = config?.urlAndroidStore ?? '';
    final apkUrl = config?.urlFileAndroidApk ?? '';
    final demoScreenshot = config?.demoScreenshot ?? '';

    // Build list buttons: check link inline (URL non-empty + browser match).
    // Không cần biến trung gian hasIos/hasAndroid/hasApk — đọc thẳng URL.
    final buttons = <Widget>[
      if (!isWebIOSBrowser && androidUrl.isNotEmpty)
        _StoreButton(
          path: AppImages.imageDownloadByAndroid,
          onTap: onAndroidStore,
        ),
      if (!isWebIOSBrowser && apkUrl.isNotEmpty)
        _StoreButton(path: AppImages.imageDownloadByAndroidAPK, onTap: onApk),
      if (!isWebAndroidBrowser && iosUrl.isNotEmpty)
        _StoreButton(path: AppImages.imageDownloadByIos, onTap: onIosStore),
    ];

    // Không có button nào → ẩn toàn bộ section.
    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageHelper.load(
              path: demoScreenshot,
              width: 162,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContentForApp(description: 'Tăng tốc tải ứng dụng'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Nạp rút tức thì'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Trải nghiệm mượt mà'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Tiết kiệm dung lượng'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < buttons.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          buttons[i],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ImageHelper.load(path: path, width: 172, fit: BoxFit.contain),
    );
  }
}
