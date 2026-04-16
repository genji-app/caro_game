import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

class ProfilePhoneVerifiedIcon extends StatelessWidget {
  const ProfilePhoneVerifiedIcon({super.key, this.size});

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return ImageHelper.getSVG(
      width: size?.width,
      height: size?.height,
      path: AppIcons.iconVerified,
    );
  }
}
