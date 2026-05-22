// ignore_for_file: unnecessary_library_name

/// Game API Client
///
/// This library provides a client for interacting with Game API.
///
/// ## Features
/// - Automatic token refresh
/// - Type-safe error handling
/// - Business error detection
/// - Network error handling
///
/// ## Usage
///
/// ### Setup
/// ```dart
/// // Pre-configured full URL including the path (e.g. /gameapi/public)
/// final gameApiUrl = 'https://api.domain.com/gameapi/public';
///
/// final dio = GameApiClient.createDioClient(gameApiUrl, () async {
///   // Optional: Your token refresh logic for 401 retries
///   return await authService.refreshToken();
/// });
///
/// final client = GameApiClient(
///   dio: dio,
///   tokenProvider: () async => 'your-session-token',
/// );
/// ```
///
/// ### Get Games List
/// ```dart
/// try {
///   final providers = await client.getGames();
///   // Returns List<ProviderGames> directly
///   for (final provider in providers) {
///     print(provider.providerName);
///   }
/// } catch (e) {
///   if (e is DioException && e.isGameApiException) {
///     final gameEx = e.gameApiException!;
///     print('Error type: ${gameEx.type.name}');
///     print('Message: ${gameEx.message}');
///     print('User message: ${gameEx.userFriendlyMessage}');
///   }
/// }
/// ```
///
/// ### Get Game URL
/// ```dart
/// try {
///   final url = await client.getGameUrl(
///     GetGameUrlRequest(
///       providerId: 'amb-vn',
///       productId: 'SEXY',
///       gameCode: 'MX-LIVE-XX',
///       lang: 'vi',
///       isMobileLogin: true,
///     ),
///   );
///   // Returns String URL directly
///   print('Game URL: $url');
/// } catch (e) {
///   if (e is DioException && e.isGameApiException) {
///     final gameEx = e.gameApiException!;
///
///     // Check error type
///     if (gameEx.isAuthError) {
///       // Handle authentication error
///       navigateToLogin();
///     } else if (gameEx.isNetworkError) {
///       // Handle network error
///       showNoInternetDialog();
///     } else {
///       // Show error message
///       showSnackbar(gameEx.userFriendlyMessage);
///     }
///   }
/// }
/// ```
library game_api_client;

export 'src/dio_exception_extensions.dart';
export 'src/game_api_client.dart';
export 'src/game_api_exception.dart';
export 'src/models/models.dart';
