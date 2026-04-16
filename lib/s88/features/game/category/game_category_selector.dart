import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS (Category Selection State)
// ═══════════════════════════════════════════════════════════════════════════

/// Shared provider for managing game category selection state.
///
/// Used by both [GameCategorySelector] and the desktop sidebar to keep
/// casino category selection in sync.
final gameCategorySelectionProvider = StateProvider<GameCategorySelection>(
  (ref) => const GameCategorySelection(),
);

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET
// ═══════════════════════════════════════════════════════════════════════════

/// Horizontal scroll bar for selecting game categories.
///
/// ## State Management:
/// - **Internal State**: Manages selection state internally via private provider
/// - **Communication**: Uses `onSelectionChanged` callback to notify parent
///
/// ## Provider Injection (Optional):
/// - `categoryProvider`: Source of category data (defaults to [gameCategoriesProvider])
///
/// ## Usage:
/// ```dart
/// GameCategorySelector(
///   onSelectionChanged: (selection) {
///     // Handle selection change
///     print('Selected: ${selection.label}');
///   },
/// )
/// ```
class GameCategorySelector extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const GameCategorySelector({
    required this.onSelectionChanged,
    this.categoryProvider,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.preferredSize = const Size.fromHeight(62),
    super.key,
  });

  final ValueChanged<GameCategorySelection> onSelectionChanged;
  final Provider<GameCategories>? categoryProvider;
  final EdgeInsetsGeometry padding;

  @override
  final Size preferredSize;

  @override
  ConsumerState<GameCategorySelector> createState() =>
      _GameCategorySelectorState();
}

class _GameCategorySelectorState extends ConsumerState<GameCategorySelector> {
  /// Local keys to track item positions for "ensureVisible"
  final Map<int, GlobalKey> _itemKeys = {};

  void _scrollToIndex(int index) {
    // Wait for the next frame to ensure the item is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _itemKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the item
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = ref.watch(
      widget.categoryProvider ?? gameCategoriesProvider,
    );
    final selection = ref.watch(gameCategorySelectionProvider);

    // Listen to selection changes and scroll to the selected item
    ref.listen<GameCategorySelection>(gameCategorySelectionProvider, (
      prev,
      next,
    ) {
      if (prev == next) return;

      int index = 0; // Default to "All"
      if (next.category != null) {
        index =
            categoryData.categories.indexWhere(
              (c) => c.id == next.category!.id,
            ) +
            1;
      }

      if (index >= 0) {
        _scrollToIndex(index);
      }
    });

    if (categoryData.categories.isEmpty) {
      return PreferredSize(
        preferredSize: widget.preferredSize,
        child: const Center(child: Text('No categories available')),
      );
    }

    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: SizedBox.fromSize(
        size: widget.preferredSize,
        child: _buildCategoriesRow(
          context: context,
          categoryData: categoryData,
          selection: selection,
          padding: widget.padding,
          onSelectionChanged: (newSelection) {
            ref.read(gameCategorySelectionProvider.notifier).state =
                newSelection;
            widget.onSelectionChanged(newSelection);
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesRow({
    required BuildContext context,
    required GameCategories categoryData,
    required GameCategorySelection selection,
    required EdgeInsetsGeometry padding,
    required void Function(GameCategorySelection) onSelectionChanged,
  }) {
    final List<GameCategory> categories = categoryData.categories;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // Register key for this index
          final key = _itemKeys.putIfAbsent(index, () => GlobalKey());

          if (index == 0) {
            final isSelected = selection.isEmpty;
            final path = allCategoryConfig.getIconPath(active: isSelected);
            return Align(
              key: key,
              alignment: Alignment.center,
              child: GameCategoryButton(
                label: allCategoryConfig.displayName,
                isSelected: isSelected,
                onPressed: () =>
                    onSelectionChanged(const GameCategorySelection()),
                iconBuilder: (isSelected) => SizedBox(
                  key: ValueKey('category_icon_$path'),
                  child: ImageHelper.load(path: path),
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = _isCategorySelected(category, selection);

          return Align(
            key: key,
            alignment: Alignment.center,
            child: GameCategoryButton(
              label: category.label,
              isSelected: isSelected,
              badge: category.count > 0 ? '${category.count}' : null,
              onPressed: () => onSelectionChanged(
                GameCategorySelection.fromCategory(category),
              ),
              iconBuilder: (isSelected) =>
                  _buildCategoryIcon(category, isSelected),
            ),
          );
        },
      ),
    );
  }

  bool _isCategorySelected(
    GameCategory category,
    GameCategorySelection selection,
  ) {
    return selection.category?.id == category.id;
  }

  Widget _buildCategoryIcon(GameCategory category, bool isSelected) {
    final path = category.getIconPath(active: isSelected);
    return SizedBox(
      key: ValueKey('category_icon_$path'),
      child: ImageHelper.load(path: path),
    );
  }
}
