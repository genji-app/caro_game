import 'caxilo_config_exceptions.dart';

/// Base interface for in-house game launch strategies.
abstract class LaunchStrategy {
  /// Generates a launch URL for the game.
  Future<String> generateUrl({
    required String baseUrl,
    required String token,
    required String refreshToken,
    required bool isWeb,
    int? gameId,
  });

  /// Helper to get the redirect URL identifier based on platform.
  String getRu(bool isWeb) => isWeb ? 'flutter-web' : 'flutter-app';

  /// Helper to ensure a base URL of a Uri has at least a trailing slash.
  Uri parseBaseUrl(String baseUrl) {
    var uri = Uri.parse(baseUrl);
    if (uri.path.isEmpty) uri = uri.replace(path: '/');
    return uri;
  }
}

/// Strategy for standard in-house games (e.g. Avenger, Hải Tặc).
class StandardLaunchStrategy extends LaunchStrategy {
  @override
  Future<String> generateUrl({
    required String baseUrl,
    required String token,
    required String refreshToken,
    required bool isWeb,
    int? gameId,
  }) async {
    final uri = parseBaseUrl(baseUrl);
    final queryParams = <String, String>{
      ...uri.queryParameters,
      'accessToken': token,
      'refreshToken': refreshToken,
      'useCardGameWSJson': 'true',
      'ru': getRu(isWeb),
    };

    if (gameId != null) {
      queryParams['gameID'] = gameId.toString();
    }

    return uri.replace(queryParameters: queryParams).toString();
  }
}

/// Strategy for fish games (Sun Cá).
class FishLaunchStrategy extends LaunchStrategy {
  @override
  Future<String> generateUrl({
    required String baseUrl,
    required String token,
    required String refreshToken,
    required bool isWeb,
    int? gameId,
  }) async {
    final uri = parseBaseUrl(baseUrl);
    final queryParams = <String, String>{
      ...uri.queryParameters,
      'token': token,
      'ru': getRu(isWeb),
    };
    return uri.replace(queryParameters: queryParams).toString();
  }
}

/// Strategy for games currently under development.
class UnderDevelopmentLaunchStrategy extends LaunchStrategy {
  @override
  Future<String> generateUrl({
    required String baseUrl,
    required String token,
    required String refreshToken,
    required bool isWeb,
    int? gameId,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    throw const InHouseGameUnderDevelopmentException();
  }
}
