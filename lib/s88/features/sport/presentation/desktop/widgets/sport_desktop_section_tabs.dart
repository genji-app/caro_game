import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

class SportDesktopSectionTabs extends StatefulWidget {
  final List<String> sections;
  final int selectedIndex;
  final void Function(int)? onTabSelected;
  final bool isMobile;

  const SportDesktopSectionTabs({
    super.key,
    required this.sections,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.isMobile = false,
  });

  @override
  State<SportDesktopSectionTabs> createState() =>
      _SportDesktopSectionTabsState();
}

class _SportDesktopSectionTabsState extends State<SportDesktopSectionTabs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final GlobalKey _rowKey = GlobalKey();
  double? _singleSetWidth;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    // Measure the actual width after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndStartAnimation();
    });
  }

  void _measureAndStartAnimation() {
    final RenderBox? renderBox =
        _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final totalWidth = renderBox.size.width;
      // We duplicate sections 3 times, so one set is one-third of the total width
      setState(() {
        _singleSetWidth = totalWidth / 3;
      });
    }
    // Start animation with infinite repeat
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get logo for each section
  Widget? _getLogo(String section) {
    switch (section) {
      case 'Cúp C1 Châu Âu':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoChampion,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'Ngoại hạng anh':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoPremileague,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'Laliga':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoLaliga,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'Seria A':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoSeriA,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'Bundesliga':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoBundesliga,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'Ligue 1':
        return ImageHelper.getNetworkImage(
          imageUrl: AppImages.logoLeague1,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate sections 3 times for seamless infinite loop
    final duplicatedSections = [
      ...widget.sections,
      ...widget.sections,
      ...widget.sections,
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        // Calculate offset for seamless loop
                        final width = _singleSetWidth ?? 0;
                        if (width == 0) {
                          // Not measured yet, show without animation
                          return _buildTabsRow(duplicatedSections);
                        }

                        // Use modulo to create seamless loop
                        // When offset reaches width, it resets to 0 seamlessly
                        final offset =
                            (_animationController.value * width) % width;

                        return Transform.translate(
                          offset: Offset(-offset, 0),
                          child: _buildTabsRow(duplicatedSections),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF151410),
                    const Color(0xFF151410).withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF151410).withValues(alpha: 0),
                      const Color(0xFF151410),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              if (!widget.isMobile)
                Material(
                  color: const Color(0xFF302F2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(4),
                    child: ImageHelper.load(
                      path: AppIcons.btnArrowRight,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabsRow(List<String> duplicatedSections) {
    return Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: duplicatedSections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final sectionIndex = index % widget.sections.length;
        final isSelected = widget.selectedIndex == sectionIndex;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SectionTabItem(
            label: section,
            icon: _getLogo(section),
            isSelected: isSelected,
            onTap: () => widget.onTabSelected?.call(sectionIndex),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTabItem extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SectionTabItem({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(1000),
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 8, right: 15),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0x0AFFF6E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            if (icon != null)
              SizedBox(width: 32, height: 32, child: icon)
            else
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
              ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall(color: const Color(0xFFAAA49B)),
            ),
          ],
        ),
      ),
    ),
  );
}
