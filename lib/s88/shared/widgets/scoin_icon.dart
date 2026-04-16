import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

/// S Coin icon - currency unit icon from assets
/// Design from Figma: node-id=3939:13
/// Icon nằm bên phải số tiền
class SCoinIcon extends StatelessWidget {
  const SCoinIcon();

  @override
  Widget build(BuildContext context) {
    return ImageHelper.load(
      path: AppIcons.iconCurrencyUnit,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}
