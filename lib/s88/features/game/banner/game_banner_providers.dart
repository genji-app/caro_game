import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

class GameBannerProviders extends StatelessWidget {
  const GameBannerProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, type) {
        switch (type) {
          case DeviceType.mobile:
            return const _MediumBanner();
          case DeviceType.tablet:
          case DeviceType.desktop:
          case DeviceType.largeDesktop:
            return const _LargeBanner();
        }
      },
    );
  }
}

class _MediumBanner extends StatelessWidget {
  const _MediumBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ImageHelper.load(
        path: AppImages.imgGameBannerProvidersMedium,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LargeBanner extends StatelessWidget {
  const _LargeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: const BoxConstraints(maxHeight: 104, maxWidth: 860),
      child: ImageHelper.load(
        path: AppImages.imgGameBanner,
        fit: BoxFit.contain,
      ),
    );
  }
}
