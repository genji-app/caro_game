import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/unified_assets_preloader.dart';

/// Splash Screen thống nhất cho mọi platform: logo + ProgressBar đồng bộ với preload.
class S88SplashScreen extends ConsumerStatefulWidget {
  const S88SplashScreen({super.key});

  @override
  ConsumerState<S88SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<S88SplashScreen> {
  double _preloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      UnifiedAssetsPreloader.startPreloadingInBackground(
        context,
        onProgress: (progress) {
          if (mounted) setState(() => _preloadProgress = progress);
        },
        onComplete: () {
          if (mounted) _navigateToMain();
        },
      );
    });
  }

  void _navigateToMain() {
    ref.read(splashProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: ImageHelper.getNetworkImage(
                imageUrl: AppImages.logoS88Home,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorWidget: const Icon(
                  Icons.image,
                  size: 200,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: LinearProgressIndicator(
                value: _preloadProgress,
                backgroundColor: AppColorStyles.backgroundTertiary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.yellow300,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider quản lý trạng thái splash.
class SplashNotifier extends StateNotifier<bool> {
  SplashNotifier() : super(true);

  void complete() {
    state = false;
  }

  void reset() {
    state = true;
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, bool>(
  (ref) => SplashNotifier(),
);
