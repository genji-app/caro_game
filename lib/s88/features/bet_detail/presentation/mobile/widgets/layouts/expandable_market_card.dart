import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Expandable Market Card Widget
///
/// A reusable wrapper component for market layouts with:
/// - Header: Title + expand/collapse arrow
/// - Body: Content that can be expanded/collapsed
///
/// Used for all market types in the new design where each market
/// is displayed as a separate expandable card.
class ExpandableMarketCard extends StatelessWidget {
  /// Card title (e.g., "Toàn trận - Kèo chấp")
  final String title;

  /// Whether the card is expanded
  final bool isExpanded;

  /// Callback when expand/collapse is toggled
  final VoidCallback onToggle;

  /// The content to display when expanded
  final Widget child;

  const ExpandableMarketCard({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(
            color: const Color.fromRGBO(255, 255, 255, 0.12),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          // Content
          if (isExpanded) ...[_buildDivider(), child],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.textStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFCDB),
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xB3FFFCDB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
