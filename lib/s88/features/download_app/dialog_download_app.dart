import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
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

class _DownloadAppContent extends StatelessWidget {
  const _DownloadAppContent({required this.isBottomSheet});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final container = Container(
      width: MediaQuery.of(context).size.width <= 733 ? null : _dialogWidth,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: const BorderRadius.vertical(
          top: const Radius.circular(24),
        ),
        border: Border.all(color: AppColors.gray700, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DownloadHeader(onClose: () => Navigator.of(context).pop()),
            _AppDescriptionSection(),
            const SizedBox(height: 40),
            _DownloadAppSection(
              onAndroid: () => _openStore(context, isAndroid: true),
              onIos: () => _openStore(context, isAndroid: false),
            ),
          ],
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

  Future<void> _openStore(
    BuildContext context, {
    required bool isAndroid,
  }) async {
    final url = isAndroid
        ? 'https://play.google.com/store'
        : 'https://apps.apple.com/app';
    final uri = Uri.parse(url);
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

/// Mô tả ứng dụng (Figma 9054-67913): app icon + title + description
class _AppDescriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageHelper.load(
                path: AppImages.iconAppFake,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pirate Game',
                      style: AppTextStyles.headingSmall(
                        context: context,
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Game',
                      style: AppTextStyles.paragraphSmall(
                        context: context,
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lorem ipsum magna mus nisl ut leo quam molestie sed nec lectus ac velit ut dictum malesuada mattis vitae ',
            style: AppTextStyles.paragraphSmall(
              context: context,
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      ),
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
        Text(
          description,
          style: AppTextStyles.paragraphSmall(
            context: context,
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ],
    );
  }
}

List<Widget> _buildStoreButtons({
  required VoidCallback onAndroid,
  required VoidCallback onIos,
}) {
  if (isWebAndroidBrowser) {
    return [
      _StoreButton(path: AppImages.imageDownloadByAndroid, onTap: onAndroid),
    ];
  }
  if (isWebIOSBrowser) {
    return [_StoreButton(path: AppImages.imageDownloadByIos, onTap: onIos)];
  }
  return [
    _StoreButton(path: AppImages.imageDownloadByAndroid, onTap: onAndroid),
    const SizedBox(height: 16),
    _StoreButton(path: AppImages.imageDownloadByIos, onTap: onIos),
  ];
}

/// Mô tả download app: store buttons (Figma 9054-72825)
class _DownloadAppSection extends StatelessWidget {
  const _DownloadAppSection({required this.onAndroid, required this.onIos});

  final VoidCallback onAndroid;
  final VoidCallback onIos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageHelper.load(
              path: AppImages.imageAppDownload,
              width: 162,
              fit: BoxFit.contain,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContentForApp(description: 'Tăng tốc tải ứng dụng'),
                    const SizedBox(height: 12),
                    _ContentForApp(description: 'Nạp rút tức thì'),
                    const SizedBox(height: 12),
                    _ContentForApp(description: 'Trải nghiệm mượt mà'),
                    const SizedBox(height: 12),
                    _ContentForApp(description: 'Tiết kiệm dung lượng'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildStoreButtons(
                    onAndroid: onAndroid,
                    onIos: onIos,
                  ),
                ),
              ],
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
