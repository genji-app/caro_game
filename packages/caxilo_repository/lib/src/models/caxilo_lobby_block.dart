import 'caxilo_game_block.dart';

/// {@template caxilo_lobby_block}
/// Sealed class representing a single block in the game lobby.
///
/// The lobby is a vertical list composed of these blocks.
/// {@endtemplate}
sealed class CaxiloLobbyBlock {
  const CaxiloLobbyBlock();
}

/// {@template caxilo_group_block}
/// A horizontal group of games with a display label.
/// {@endtemplate}
class CaxiloGroupBlock extends CaxiloLobbyBlock {
  const CaxiloGroupBlock({required this.label, required this.games});

  /// The display title for this group.
  final String label;

  /// The list of games to be displayed in this group.
  final List<CaxiloGameBlock> games;
}

/// {@template caxilo_banner_block}
/// A promotional banner to be injected into the lobby.
/// {@endtemplate}
class CaxiloBannerBlock extends CaxiloLobbyBlock {
  const CaxiloBannerBlock({required this.bannerId, this.image});

  /// Identifies which banner to render (e.g., "providersBanner").
  final String bannerId;

  /// Optional custom image URL for the banner.
  final String? image;
}
