import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// A single category item with animated selection state
class GameCategoryButton extends StatelessWidget {
  const GameCategoryButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
    this.badge,
    this.iconBuilder,
  });

  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onPressed;
  final Widget Function(bool isSelected)? iconBuilder;

  static const constraints = BoxConstraints(minHeight: 62, minWidth: 80);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return ConstrainedBox(
      constraints: constraints,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: AppColorStyles.backgroundTertiary,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  opacity: isSelected ? 1.0 : 0.0,
                  child: ImageHelper.load(
                    path: AppImages.imgGameBgSelected,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Content (Icon + Label)
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    // Icon
                    if (iconBuilder != null) ...[
                      SizedBox.square(
                        dimension: 24,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: iconBuilder!(isSelected),
                        ),
                      ),
                    ],

                    // Label
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.paragraphXSmall(
                          color: isSelected
                              ? AppColors.yellow300
                              : AppColorStyles.contentSecondary,
                        ),
                        child: Text(label),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
