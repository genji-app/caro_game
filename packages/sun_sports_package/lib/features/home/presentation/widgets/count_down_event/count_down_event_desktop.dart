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

/// Figma: Sun-Sport node 11784:69231 — World Cup 2026 countdown banner (desktop).
class CountDownEventDesktop extends ConsumerStatefulWidget {
  const CountDownEventDesktop({super.key});

  @override
  ConsumerState<CountDownEventDesktop> createState() =>
      _CountDownEventDesktopState();
}

class _CountDownEventDesktopState extends ConsumerState<CountDownEventDesktop>
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                children: <Widget>[
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    left: 512,
                    child: ImageHelper.load(
                      path: AppImages.imgBackgroundCountDownEvent,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 28, 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const _CountDownEventBranding(),
                            const Spacer(),
                            ShineButton(
                              text: 'Cược ngay',
                              height: 36,
                              onPressed: () async {
                                await navigateToFifaWorldCup2026(ref);
                              },
                            ),
                          ],
                        ),
                        _CountDownTimerRow(
                          days: days,
                          hours: hours,
                          minutes: minutes,
                          seconds: seconds,
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

class _CountDownEventBranding extends StatelessWidget {
  const _CountDownEventBranding();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ImageHelper.load(
          path: AppImages.iconCountDownWC,
          height: 52,
          fit: BoxFit.contain,
        ),
        const Gap(16),
        Text(
          'World Cup\n2026',
          style: AppTextStyles.headingXSmall(
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ],
    );
  }
}

class _CountDownTimerRow extends StatelessWidget {
  const _CountDownTimerRow({
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
        _CountDownDigitBox(
          value: days.toString().padLeft(2, '0'),
          label: 'Ngày',
        ),
        const Gap(8),
        _CountDownDigitBox(
          value: hours.toString().padLeft(2, '0'),
          label: 'Giờ',
        ),
        const Gap(8),
        _CountDownDigitBox(
          value: minutes.toString().padLeft(2, '0'),
          label: 'Phút',
        ),
        const Gap(8),
        _CountDownDigitBox(
          value: seconds.toString().padLeft(2, '0'),
          label: 'Giây',
        ),
      ],
    );
  }
}

class _CountDownDigitBox extends StatelessWidget {
  const _CountDownDigitBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingSmall(
              color: AppColors.yellow300,
            ).copyWith(fontWeight: FontWeight.w700, height: 28 / 24),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelXXSmall(
              color: AppColorStyles.contentPrimary,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
