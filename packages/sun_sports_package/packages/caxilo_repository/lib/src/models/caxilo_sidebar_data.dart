import 'caxilo_category.dart';

/// Represents a group of categories in the sidebar.
class CaxiloSidebarGroup {
  /// Unique identifier for the group.
  final String id;

  /// Optional display title for the group.
  final String? title;

  /// List of categories in this group.
  final List<CaxiloCategory> categories;

  /// Creates a new [CaxiloSidebarGroup] instance.
  const CaxiloSidebarGroup({required this.id, required this.categories, this.title});
}

/// Unified data structure for the casino sidebar.
class CaxiloSidebarData {
  /// List of category groups to display.
  final List<CaxiloSidebarGroup> groups;

  /// Creates a new [CaxiloSidebarData] instance.
  const CaxiloSidebarData({required this.groups});
}
