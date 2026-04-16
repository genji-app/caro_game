import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class HomeMobileBannerSection extends StatelessWidget {
  const HomeMobileBannerSection({super.key});

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            offset: const Offset(0, 0.5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Positioned(
            //   left: -40,
            //   top: -15,
            //   child: Container(
            //     width: 150,
            //     height: 120,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       gradient: RadialGradient(
            //         colors: [Colors.white.withOpacity(0.06), Colors.transparent],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              right: -375.845,
              top: -125,
              child: Container(
                width: 772.69,
                height: 135.189,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(772.69),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.white.withOpacity(0.44),
                      const Color(0xFF8F8F8F).withOpacity(0.44),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  // child: Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.transparent,
                  //     borderRadius: BorderRadius.circular(772.69),
                  //   ),
                  // ),
                ),
              ),
            ),

            Positioned(
              left: -185.845,
              bottom: -130,
              child: Container(
                width: 772.69,
                height: 135.189,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(772.69),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Color(0xFF8F8F8F).withOpacity(0.44)],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(386.345),
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   right: -40,
            //   bottom: -20,
            //   child: Container(
            //     width: 150,
            //     height: 120,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       gradient: RadialGradient(
            //         colors: [Colors.white.withOpacity(0.06), Colors.transparent],
            //       ),
            //     ),
            //   ),
            // ),
            Center(
              child: Text(
                'Volta banner',
                style: AppTextStyles.headingSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
