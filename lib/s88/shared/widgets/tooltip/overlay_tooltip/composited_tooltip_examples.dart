/// Example usage of CompositedTooltipController
///
/// This file demonstrates how to use the reusable CompositedTooltipController
/// component for tooltips in scrollable lists.

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

/// Example: Simple tooltip button
class SimpleTooltipButton extends StatefulWidget {
  const SimpleTooltipButton({super.key});

  @override
  State<SimpleTooltipButton> createState() => _SimpleTooltipButtonState();
}

class _SimpleTooltipButtonState extends State<SimpleTooltipButton> {
  // ✅ Create controller instance
  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    // ✅ Clean up
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _tooltipController.show(
      context: context,
      builder: (onClose) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'This is a tooltip!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap button with target
    return _tooltipController.wrapTarget(
      child: IconButton(onPressed: _showTooltip, icon: const Icon(Icons.info)),
    );
  }
}

/// Example: Tooltip with custom positioning
class CustomPositionTooltip extends StatefulWidget {
  const CustomPositionTooltip({super.key});

  @override
  State<CustomPositionTooltip> createState() => _CustomPositionTooltipState();
}

class _CustomPositionTooltipState extends State<CustomPositionTooltip> {
  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _tooltipController.show(
      context: context,
      // ✅ Custom anchors and offset
      targetAnchor: Alignment.topCenter,
      followerAnchor: Alignment.bottomCenter,
      offset: const Offset(0, -8),
      autoCloseOnScroll: true,
      builder: (onClose) => const TooltipContainer(
        width: 200,
        arrowPosition: ArrowPosition.bottom,
        child: Text('Tooltip above button'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: ElevatedButton(
        onPressed: _showTooltip,
        child: const Text('Show Tooltip'),
      ),
    );
  }
}

/// Example: Tooltip in scrollable list
class TooltipInList extends StatefulWidget {
  const TooltipInList({super.key});

  @override
  State<TooltipInList> createState() => _TooltipInListState();
}

class _TooltipInListState extends State<TooltipInList> {
  final List<CompositedTooltipController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Create controller for each item
    for (int i = 0; i < 20; i++) {
      _controllers.add(CompositedTooltipController());
    }
  }

  @override
  void dispose() {
    // Clean up all controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showTooltip(int index) {
    _controllers[index].show(
      context: context,
      autoCloseOnScroll: true, // ✅ Auto-close when scrolling
      builder: (onClose) => TooltipContainer(
        width: 250,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        child: Text('Tooltip for item $index'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          trailing: _controllers[index].wrapTarget(
            child: IconButton(
              onPressed: () => _showTooltip(index),
              icon: const Icon(Icons.help_outline),
            ),
          ),
        );
      },
    );
  }
}

/// Example: Refactored BetSlipExplanationButton
///
/// This shows how to refactor the existing implementation
/// to use CompositedTooltipController
class BetSlipExplanationButtonExample extends StatefulWidget {
  const BetSlipExplanationButtonExample({super.key});

  @override
  State<BetSlipExplanationButtonExample> createState() =>
      _BetSlipExplanationButtonExampleState();
}

class _BetSlipExplanationButtonExampleState
    extends State<BetSlipExplanationButtonExample> {
  // ✅ BEFORE: Manual LayerLink + OverlayEntry
  // final LayerLink _layerLink = LayerLink();
  // OverlayEntry? _overlayEntry;
  // ScrollPosition? _scrollPosition;
  // ... lots of boilerplate code

  // ✅ AFTER: Just use the controller!
  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    // Your hint data logic
    final hintData = _getHintData();
    if (hintData == null) return;

    const tooltipWidth = 326.0;

    // ✅ Simple and clean!
    _tooltipController.show(
      context: context,
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      offset: const Offset(-12, 12),
      autoCloseOnScroll: true,
      builder: (onClose) => TooltipContainer(
        width: tooltipWidth,
        padding: EdgeInsets.zero,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        child: Text('Hint: $hintData'),
      ),
    );
  }

  dynamic _getHintData() => 'Sample hint data';

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: IconButton(onPressed: _showTooltip, icon: const Icon(Icons.info)),
    );
  }
}
