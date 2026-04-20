import 'package:dio/dio.dart';

import 'game_api_error_interceptor.dart';
import 'game_api_exception.dart';
import 'game_api_token_refresh_interceptor.dart';
import 'models/models.dart';

/// Signature for the authentication token provider.
typedef TokenProvider = Future<String?> Function();

/// {@template game_api_client}
/// HTTP client for interacting with the Game API.
///
/// Handles game listing and game URL generation with automatic
/// token management and error handling.
/// {@endtemplate}
class GameApiClient {
  /// {@macro game_api_client}
  GameApiClient({required Dio dio, required TokenProvider tokenProvider})
      : _dio = dio,
        _tokenProvider = tokenProvider;

  final Dio _dio;
  final TokenProvider _tokenProvider;

  /// Creates a [Dio] client pre-configured with the necessary interceptors
  /// for Game API communication.
  ///
  /// The [baseUrl] should be the API domain combined with the game API
  /// bounded context path (e.g. `https://api.domain.com/gameapi/public`).
  ///
  /// Optionally accepts an [onRefreshToken] callback for handling 401 errors
  /// through the [GameApiTokenRefreshInterceptor].
  static Dio createDioClient(
    String baseUrl, [
    TokenRefreshCallback? onRefreshToken,
  ]) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => true,
      ),
    );

    // Add token refresh interceptor if callback provided
    if (onRefreshToken != null) {
      dio.interceptors.add(
        GameApiTokenRefreshInterceptor(
          onRefreshToken: onRefreshToken,
          dio: dio, // ✅ Pass Dio instance for retries
        ),
      );
    }

    // Error interceptor should be last to catch all errors
    dio.interceptors.add(GameApiErrorInterceptor());

    return dio;
  }

  /// Retrieves the standard headers for Game API requests.
  ///
  /// Includes the 'Content-Type' and 'Authorization' token if available.
  Future<Map<String, String>> _getRequestHeaders() async {
    final token = await _tokenProvider();
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };
  }

  /// Fetches the list of all available game providers and their associated games.
  ///
  /// Returns a [List] of [ProviderGames].
  ///
  /// Throws a [DioException] (wrapping a [GameApiException]) if the request
  /// fails or the server returns a business error.
  Future<List<ProviderGames>> getGames() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/providers/games',
      options: Options(headers: await _getRequestHeaders()),
    );

    // Parse API response (interceptor already rejected failures)
    final apiResponse = GameApiResponse.fromJson(
      response.data!,
      (json) =>
          (json as List).map((e) => ProviderGames.fromJson(e as Map<String, dynamic>)).toList(),
    );

    // Unwrap and return data directly
    return apiResponse.dataOrThrow;
  }

  /// Generates a launch URL for a specific game based on the [request] parameters.
  ///
  /// Returns the game URL as a [String].
  ///
  /// Throws a [DioException] (wrapping a [GameApiException]) if the request
  /// fails, parameters are invalid, or server returns an error.
  Future<String> getGameUrl(GetGameUrlRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/providers/get-url',
      options: Options(headers: await _getRequestHeaders()),
      data: request.toApiJson(),
    );

    // Parse API response (interceptor already rejected failures)
    final apiResponse = GameApiResponse.fromJson(
      response.data!,
      (json) => GameUrlData.fromJson(json as Map<String, dynamic>),
    );

    // Unwrap and return URL directly
    return apiResponse.dataOrThrow.url;
  }
}

/// Internal extension for unwrapping [GameApiResponse] data.
extension _GameApiResponseClientX<T> on GameApiResponse<T> {
  /// Unwraps the success data or throws a [GameApiException] representing
  /// the failure.
  ///
  /// This is used internally by [GameApiClient] after the [GameApiErrorInterceptor]
  /// has processed the raw response.
  T get dataOrThrow => map(
        success: (s) => s.data,
        failure: (f) => throw GameApiException(
          message: f.message,
          code: f.code,
          status: f.status,
          data: f.data,
        ),
      );
}
