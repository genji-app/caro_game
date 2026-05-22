import 'caxilo_category.dart';

/// {@template caxilo_categories}
/// A container for a list of game categories.
/// {@endtemplate}
class CaxiloCategories {
  /// {@macro caxilo_categories}
  const CaxiloCategories({required this.all, this.categories = const []});

  /// The "All" category (Lobby).
  final CaxiloCategory all;

  /// List of other specific categories.
  final List<CaxiloCategory> categories;
}
