import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// A reusable widget designed to display a section with a title and a horizontal carousel
/// of items with pagination controls.
class HorizontalPaginatedCarousel extends StatefulWidget {
  const HorizontalPaginatedCarousel({
    required this.itemCount,
    required this.itemBuilder,
    required this.columnsBuilder,
    required this.heightBuilder,
    required this.horizontalPadding,
    required this.itemSpacing,
    super.key,
    this.title,
    this.backgroundColor = AppColorStyles.backgroundTertiary,
    this.cardBorderRadius = 12.0,
    this.actionWidget,
  });

  /// The title of the section, can be omitted or null
  final Widget? title;

  /// Number of items in the carousel
  final int itemCount;

  /// Builder for generating an item widget at a given index
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Determines the number of total columns based on available width.
  final int Function(double availableWidth) columnsBuilder;

  /// Determines height based on calculated card width.
  final double Function(double cardWidth) heightBuilder;

  /// Optional additional widget to display in the header
  final Widget? actionWidget;

  /// Background color of the card
  final Color backgroundColor;

  /// Border radius of the inner card
  final double cardBorderRadius;

  /// Horizontal padding at the start and end of the carousel.
  final double horizontalPadding;

  /// Spacing between items in the carousel.
  final double itemSpacing;

  @override
  State<HorizontalPaginatedCarousel> createState() =>
      _HorizontalPaginatedCarouselState();
}

class _HorizontalPaginatedCarouselState
    extends State<HorizontalPaginatedCarousel> {
  late final CarouselSliderController _carouselController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  void _goToPreviousPage() {
    _carouselController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    _carouselController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      borderRadius: widget.cardBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cardBorderRadius),
          color: widget.backgroundColor,
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;

              // Layout Calculation
              final columns = widget.columnsBuilder(availableWidth);
              final paddingH = widget.horizontalPadding;
              final spacing = widget.itemSpacing;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(columns),
                  _buildCarousel(availableWidth, columns, paddingH, spacing),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int columns) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 12),
          if (widget.title != null)
            DefaultTextStyle(
              style: AppTextStyles.labelMedium(
                context: context,
                color: AppColorStyles.contentPrimary,
              ),
              child: widget.title!,
            ),
          if (widget.title != null && widget.actionWidget != null)
            const SizedBox(width: 8),
          if (widget.actionWidget != null) widget.actionWidget!,
          const Spacer(),
          _SectionNavigationControls(
            onNextPage: _currentPage < widget.itemCount - columns
                ? _goToNextPage
                : null,
            onPreviousPage: _currentPage > 0 ? _goToPreviousPage : null,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildCarousel(
    double availableWidth,
    int columns,
    double paddingH,
    double spacing,
  ) {
    // Dimensions Calculation
    final viewportFraction = 1.0 / columns;
    final contentWidth = availableWidth - (2 * paddingH);
    final cardWidth = (contentWidth - (columns - 1) * spacing) / columns;
    final dynamicHeight = widget.heightBuilder(cardWidth);

    // Padding Calculation for CarouselSlider
    // We adjust the horizontal padding to account for item spacing
    final carouselPadding = (paddingH - spacing / 2).clamp(
      0.0,
      double.infinity,
    );
    final itemPadding = spacing / 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: carouselPadding),
      child: SizedBox(
        height: dynamicHeight,
        child: CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.itemCount,
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: itemPadding),
              child: widget.itemBuilder(context, index),
            );
          },
          options: CarouselOptions(
            height: dynamicHeight,
            viewportFraction: viewportFraction,
            enableInfiniteScroll: false,
            scrollDirection: Axis.horizontal,
            padEnds: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class _SectionNavigationControls extends StatelessWidget {
  const _SectionNavigationControls({this.onPreviousPage, this.onNextPage});

  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: [
        _SectionNavigationButton(
          direction: TextDirection.rtl,
          onPressed: onPreviousPage,
        ),
        _SectionNavigationButton(
          direction: TextDirection.ltr,
          onPressed: onNextPage,
        ),
      ],
    );
  }
}

class _SectionNavigationButton extends StatelessWidget {
  const _SectionNavigationButton({
    this.onPressed,
    this.direction = TextDirection.ltr,
  });

  final TextDirection direction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColorStyles.backgroundQuaternary,
          disabledBackgroundColor: AppColorStyles.backgroundQuaternary,
          foregroundColor: AppColorStyles.contentSecondary,
          disabledForegroundColor: AppColorStyles.contentQuaternary,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadiusDirectional.horizontal(
              end: Radius.circular(12),
            ).resolve(direction),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size.square(32),
          padding: EdgeInsets.zero,
          iconSize: 20,
        ),
        icon: const Icon(Icons.chevron_right),
      ),
    );
  }
}
