import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'hint_content_builder.dart';
import 'hint_service.dart';

/// Hint Bubble Colors
class HintColors {
  HintColors._();

  // Background
  static const bubbleBackground = Color(0xFF2A2A2A);
  static const bubbleBorder = Color(0xFFFEE4B1);

  // Text colors
  static const titleColor = Color(0xFFFEE4B1);
  static const simpleColor = Color(0xFFFFE991);
  static const teamColor = Color(0xFFFBB877);
  static const highlightColor = Color(0xFFFFE991);
  static const positiveColor = Color(0xFF2E90FA);
  static const negativeColor = Color(0xFFF63D68);
  static const defaultText = Colors.white;
}

/// Hint Bubble Widget
///
/// Displays hint information with animation when user taps the info icon.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md Section 6
class HintBubbleWidget extends StatefulWidget {
  final String title;
  final HintContent content;
  final double ratio;
  final VoidCallback onClose;

  const HintBubbleWidget({
    required this.title,
    required this.content,
    required this.ratio,
    required this.onClose,
    super.key,
  });

  @override
  State<HintBubbleWidget> createState() => _HintBubbleWidgetState();
}

class _HintBubbleWidgetState extends State<HintBubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
      decoration: BoxDecoration(
        color: HintColors.bubbleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HintColors.bubbleBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const Divider(color: HintColors.bubbleBorder, height: 1),

          // Content - using static builder (optimized)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: HintContentBuilder.buildContent(
                content: widget.content,
                ratio: widget.ratio,
                style: const HintContentStyle(
                  simpleColor: HintColors.simpleColor,
                  defaultColor: HintColors.defaultText,
                  highlightColor: HintColors.highlightColor,
                  positiveColor: HintColors.positiveColor,
                  negativeColor: HintColors.negativeColor,
                ),
                useGap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.title.toUpperCase(),
              style: AppTextStyles.labelMedium(
                color: HintColors.titleColor,
              ).copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show Hint Bubble Dialog
///
/// Shows the hint bubble as an overlay dialog
Future<void> showHintBubble({
  required BuildContext context,
  required String title,
  required HintContent content,
  required double ratio,
}) async {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    builder: (context) => Center(
      child: HintBubbleWidget(
        title: title,
        content: content,
        ratio: ratio,
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
