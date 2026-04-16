import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';

/// Item types for the game feed
sealed class GameFeedBlock {
  const GameFeedBlock();
}

class GameGroupBlock extends GameFeedBlock {
  const GameGroupBlock({required this.label, required this.games});

  final String label;
  final List<GameBlock> games;
}

class GameBannerBlock extends GameFeedBlock {
  const GameBannerBlock({this.image});

  final String? image;

  static GameBannerBlock providersBanner = const GameBannerBlock();
}
