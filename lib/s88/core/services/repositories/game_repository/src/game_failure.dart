import 'package:dio/dio.dart';
import 'package:game_api_client/game_api_client.dart';

import 'game_in_house_api_client/game_in_house_api_client.dart';

/// {@template game_failure}
/// A base failure for the game repository failures.
/// {@endtemplate}
sealed class GameFailure implements Exception {
  /// {@macro game_failure}
  const GameFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => '$runtimeType: $error';
}

/// {@template get_games_failure}
/// Thrown when fetching games list fails.
/// {@endtemplate}
class GetGamesFailure extends GameFailure {
  /// {@macro get_games_failure}
  const GetGamesFailure(super.error);
}

/// {@template get_game_url_failure}
/// Thrown when fetching game URL fails.
/// {@endtemplate}
class GetGameUrlFailure extends GameFailure {
  /// {@macro get_game_url_failure}
  const GetGameUrlFailure(super.error);
}

/// {@template game_maintenance_failure}
/// Thrown when a game is currently under maintenance.
/// {@endtemplate}
class GameMaintenanceFailure extends GameFailure {
  /// {@macro game_maintenance_failure}
  const GameMaintenanceFailure(super.error);
}

/// {@template get_game_categories_failure}
/// Thrown when fetching game category data fails.
/// {@endtemplate}
class GetGameCategoriesFailure extends GameFailure {
  /// {@macro get_game_categories_failure}
  const GetGameCategoriesFailure(super.error);
}

/// Extension to helpers for [GameFailure]
extension GameFailureX on GameFailure {
  /// Get user friendly error message
  String? get errorMessage {
    final err = error;

    // Handle GameMaintenanceFailure
    if (this is GameMaintenanceFailure) {
      return 'Trò chơi này đang bảo trì. Vui lòng quay lại sau!';
    }

    // Handle LocalGameUrlFetchException directly
    if (err is GameInHouseUrlFetchException) {
      return 'Không thể tải trò chơi!';
    }

    // Handle LocalGameUnderDevelopmentException directly
    if (err is GameInHouseUnderDevelopmentException) {
      return 'Trò chơi này đang được phát triển!';
    }

    // Handle GameApiException directly
    if (err is GameApiException) {
      return err.userFriendlyMessage;
    }

    // Handle DioException wrapping GameApiException
    if (err is DioException && err.isGameApiException) {
      return err.gameApiException!.userFriendlyMessage;
    }

    // Handle generic Exception
    if (err is Exception) {
      return err.toString().replaceFirst('Exception: ', '');
    }

    // Default message
    return null;
  }
}
