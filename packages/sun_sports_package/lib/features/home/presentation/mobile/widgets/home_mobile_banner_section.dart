import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/banner/game_banner_providers.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeMobileBannerSection extends StatelessWidget {
  const HomeMobileBannerSection({super.key});

  @override
  Widget build(BuildContext context) => const GameBannerProviders();
}