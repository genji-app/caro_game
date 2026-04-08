import 'dart:math';
import 'package:flutter/material.dart';
import '../core/l10n.dart';
import '../core/text_app_style.dart';
import '../core/game_history.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;
  final bool vsAI;
  final int totalMoves;
  final int durationSecs;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const ResultScreen({
    super.key,
    required this.result,
    required this.vsAI,
    required this.totalMoves,
    required this.durationSecs,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _scale = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _mainColor {
    switch (widget.result) {
      case GameResult.xWins: return const Color(0xFF4fc3f7);
      case GameResult.oWins: return const Color(0xFFf48fb1);
      case GameResult.draw: return const Color(0xFFFFD700);
      case GameResult.timeout: return Colors.orange;
    }
  }

  String get _resultTitle {
    switch (widget.result) {
      case GameResult.xWins:
        return widget.vsAI ? l10n.youWin : l10n.xWins;
      case GameResult.oWins:
        return widget.vsAI ? l10n.aiWins : l10n.oWins;
      case GameResult.draw:
        return l10n.draw;
      case GameResult.timeout:
        return l10n.timeout;
    }
  }

  String get _durationText {
    final m = widget.durationSecs ~/ 60;
    final s = widget.durationSecs % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _particleCtrl, _pulseCtrl]),
        builder: (_, __) {
          return Stack(
            children: [
              // Particle burst
              if (widget.result != GameResult.draw &&
                  widget.result != GameResult.timeout)
                ..._buildParticles(),
              // Main card
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: min(MediaQuery.of(context).size.width - 48, 340),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1a1a3e),
                            Color(0xFF0d0d22),
                          ],
                        ),
                        border: Border.all(
                            color: _mainColor.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: _mainColor.withValues(alpha: 0.15 + _pulseCtrl.value * 0.1),
                            blurRadius: 40 + _pulseCtrl.value * 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Big emoji
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _mainColor.withValues(alpha: 0.1),
                              border: Border.all(
                                  color: _mainColor.withValues(alpha: 0.5),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: _mainColor.withValues(alpha: 0.2 + _pulseCtrl.value * 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                l10n.resultListMark(widget.result),
                                style: TextAppStyle.ui(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: _mainColor,
                                ).copyWith(
                                  shadows: [
                                    Shadow(
                                      color: _mainColor,
                                      blurRadius: 15 + _pulseCtrl.value * 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _resultTitle,
                            textAlign: TextAlign.center,
                            style: TextAppStyle.pressStart2p(
                              color: _mainColor,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                    color: _mainColor.withValues(alpha: 0.6),
                                    blurRadius: 10)
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stats
                          _StatRow(
                            icon: Icons.grid_on,
                            label: l10n.totalMoves,
                            value: '${widget.totalMoves}',
                            color: _mainColor,
                          ),
                          const SizedBox(height: 8),
                          _StatRow(
                            icon: Icons.timer_outlined,
                            label: l10n.duration,
                            value: _durationText,
                            color: _mainColor,
                          ),
                          const SizedBox(height: 28),
                          // Buttons
                          GestureDetector(
                            onTap: widget.onPlayAgain,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    _mainColor,
                                    _mainColor.withValues(alpha: 0.7)
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: _mainColor.withValues(alpha: 0.3),
                                      blurRadius: 12)
                                ],
                              ),
                              child: Text(
                                l10n.playAgain,
                                textAlign: TextAlign.center,
                                style: TextAppStyle.rajdhani(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: widget.onHome,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: _mainColor.withValues(alpha: 0.4)),
                                color: _mainColor.withValues(alpha: 0.08),
                              ),
                              child: Text(
                                l10n.backHome,
                                textAlign: TextAlign.center,
                                style: TextAppStyle.rajdhani(
                                  color: _mainColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles() {
    final size = MediaQuery.of(context).size;
    final rng = Random(0);
    return List.generate(20, (i) {
      final angle = (i / 20) * 2 * pi;
      final speed = 80 + rng.nextDouble() * 120;
      final progress = (_particleCtrl.value + i / 20) % 1.0;
      final x = size.width / 2 + cos(angle) * speed * progress;
      final y = size.height / 2 + sin(angle) * speed * progress - 200 * progress * progress;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      return Positioned(
        left: x - 4,
        top: y - 4,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i % 2 == 0 ? _mainColor : Colors.white,
              boxShadow: [BoxShadow(color: _mainColor, blurRadius: 4)],
            ),
          ),
        ),
      );
    });
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 10),
          Text(
              label,
              style: TextAppStyle.ui(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          const Spacer(),
          Text(
              value,
              style: TextAppStyle.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}
