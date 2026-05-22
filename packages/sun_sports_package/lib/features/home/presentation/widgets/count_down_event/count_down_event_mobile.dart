import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_navigation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/borders/animated_gradient_border_painter.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

/// Figma: Sun-Sport node 11784:69492 — World Cup 2026 countdown banner (mobile).
class CountDownEventMobile extends ConsumerStatefulWidget {
  const CountDownEventMobile({super.key});

  @override
  ConsumerState<CountDownEventMobile> createState() => _CountDownEventMobileState();
}

class _CountDownEventMobileState extends ConsumerState<CountDownEventMobile>
    with TickerProviderStateMixin {
  static const Color _gradientBottom = Color(0xFF5B2800);
  static const Color _gradientTop = Color(0xFFB95100);
  static const Color _borderHighlight = Color(0xFFB95100);
  static const Color _borderSpark = Color(0xFFFFFFFF);
  static const double _borderStrokeWidth = 1.5;
  static const double _borderGlowBlur = 4;
  static const Duration _borderRotationDuration = Duration(seconds: 3);

  /// Trận khai mạc World Cup 2026: Mexico vs Nam Phi.
  /// Giờ kick-off: 02:00 ngày 12/06/2026 (giờ Việt Nam, UTC+7)
  /// = 19:00 ngày 11/06/2026 UTC.
  static final DateTime _worldCupStartDate = DateTime.utc(2026, 6, 11, 19, 0);

  Timer? _timer;
  Duration _remaining = Duration.zero;
  late final AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _tickCountdown();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
    _borderController = AnimationController(
      vsync: this,
      duration: _borderRotationDuration,
    )..repeat();
    // Pre-fetch league info để khi user click "Cược ngay", FIFA WC 2026
    // đã có sẵn trong cache — điều hướng tức thì không cần đợi API.
    prewarmFifaWorldCup2026Data(ref);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _borderController.dispose();
    super.dispose();
  }

  void _tickCountdown() {
    final Duration difference = _worldCupStartDate.difference(DateTime.now());
    final Duration nextRemaining = difference.isNegative
        ? Duration.zero
        : difference;
    if (nextRemaining == _remaining) {
      return;
    }
    setState(() => _remaining = nextRemaining);
  }

  @override
  Widget build(BuildContext context) {
    final int days = _remaining.inDays;
    final int hours = _remaining.inHours.remainder(24);
    final int minutes = _remaining.inMinutes.remainder(60);
    final int seconds = _remaining.inSeconds.remainder(60);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedBuilder(
        animation: _borderController,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            foregroundPainter: AnimatedGradientBorderPainter(
              rotation: _borderController.value,
              borderRadius: 16,
              strokeWidth: _borderStrokeWidth,
              glowBlur: _borderGlowBlur,
              highlight: _borderHighlight,
              spark: _borderSpark,
            ),
            child: child,
          );
        },
        child: InnerShadowCard(
          borderRadius: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[_gradientBottom, _gradientTop],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Positioned(
                    top: -64,
                    right: -0.5,
                    width: 232,
                    height: 138,
                    child: ImageHelper.load(
                      path: AppImages.imgBackgroundCountDownEvent,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _CountDownMobileInfo(
                            days: days,
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                          ),
                        ),
                        const Gap(8),
                        ShineButton(
                          text: 'Cược ngay',
                          height: 36,
                          onPressed: () async {
                            await navigateToFifaWorldCup2026(ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountDownMobileInfo extends StatelessWidget {
  const _CountDownMobileInfo({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ImageHelper.load(
          path: AppImages.iconCountDownWC,
          height: 32,
          fit: BoxFit.contain,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'World Cup 2026',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingXSmall(
                  color: AppColorStyles.contentPrimary,
                ).copyWith(height: 24 / 20),
              ),
              const Gap(4),
              const _CountDownMobileDivider(),
              const Gap(4),
              _CountDownInlineTimer(
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: seconds,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountDownMobileDivider extends StatelessWidget {
  const _CountDownMobileDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _CountDownInlineTimer extends StatelessWidget {
  const _CountDownInlineTimer({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _CountDownTimeSegment(
          value: days.toString().padLeft(2, '0'),
          unit: 'D',
        ),
        const _CountDownColon(),
        _CountDownTimeSegment(
          value: hours.toString().padLeft(2, '0'),
          unit: 'H',
        ),
        const _CountDownColon(),
        _CountDownTimeSegment(
          value: minutes.toString().padLeft(2, '0'),
          unit: 'M',
        ),
        const _CountDownColon(),
        _CountDownTimeSegment(
          value: seconds.toString().padLeft(2, '0'),
          unit: 'S',
        ),
      ],
    );
  }
}

class _CountDownTimeSegment extends StatelessWidget {
  const _CountDownTimeSegment({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: AppTextStyles.labelXSmall(
            color: AppColors.yellow300,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(2),
        Text(
          unit,
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentPrimary,
          ).copyWith(
            fontWeight: FontWeight.w500,
            color: AppColorStyles.contentPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _CountDownColon extends StatelessWidget {
  const _CountDownColon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: AppTextStyles.labelXSmall(
          color: AppColorStyles.contentPrimary,
        ).copyWith(
          fontWeight: FontWeight.w700,
          color: AppColorStyles.contentPrimary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
