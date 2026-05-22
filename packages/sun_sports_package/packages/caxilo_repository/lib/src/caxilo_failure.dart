import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:game_api_client/game_api_client.dart' as gac;

/// {@template caxilo_failure}
/// Base sealed class for all Caxilo repository failures.
///
/// Callers should catch [CaxiloFailure] and switch on the subtype for
/// exhaustive handling. The [source] field preserves the original exception
/// for logging — presentation layer should not read it directly.
/// {@endtemplate}
sealed class CaxiloFailure implements Exception {
  /// {@macro caxilo_failure}
  const CaxiloFailure({this.source, this.message});

  /// The original exception that caused this failure. For logging only.
  final Object? source;

  /// Optional human-readable message from the API or system.
  /// Safe to display in UI. Null if unavailable.
  final String? message;

  /// Whether the operation can be retried and may succeed.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType(message: $message, source: $source)';
}

// ---------------------------------------------------------------------------
// Concrete domain failure types
// ---------------------------------------------------------------------------

/// Network connectivity error or request timeout.
final class CaxiloNetworkFailure extends CaxiloFailure {
  const CaxiloNetworkFailure({super.source});

  @override
  bool get isRetryable => true;
}

/// Authentication failure — token expired, 401, 403, session invalid.
/// Not retryable: the user must re-authenticate.
final class CaxiloAuthFailure extends CaxiloFailure {
  const CaxiloAuthFailure({super.source});
}

/// The game is currently under maintenance (confirmed by server or settings).
final class CaxiloMaintenanceFailure extends CaxiloFailure {
  const CaxiloMaintenanceFailure({super.source});
}

/// Base class for games that are unavailable for a specific reason.
sealed class CaxiloGameUnavailableFailure extends CaxiloFailure {
  const CaxiloGameUnavailableFailure({super.source});
}

/// The game has not launched yet.
final class CaxiloComingSoonFailure extends CaxiloGameUnavailableFailure {
  const CaxiloComingSoonFailure({super.source});
}

/// The game has been disabled by the operator.
final class CaxiloDisabledFailure extends CaxiloGameUnavailableFailure {
  const CaxiloDisabledFailure({super.source});
}

/// The game is still under development.
final class CaxiloUnderDevelopmentFailure extends CaxiloGameUnavailableFailure {
  const CaxiloUnderDevelopmentFailure({super.source});
}

/// Server-side error (5xx). May succeed on retry.
final class CaxiloServerFailure extends CaxiloFailure {
  const CaxiloServerFailure({super.message, super.source});

  @override
  bool get isRetryable => true;
}

/// Business logic error returned by the API with an operator-defined message.
///
/// The message field carries the raw API message and should be displayed
/// directly to the user (e.g. "Tài khoản bị khóa", "Số dư không đủ").
final class CaxiloBusinessFailure extends CaxiloFailure {
  const CaxiloBusinessFailure({required String message, super.source}) : super(message: message);
}

/// Catch-all for errors that do not match any known domain type.
final class CaxiloUnknownFailure extends CaxiloFailure {
  const CaxiloUnknownFailure({super.message, super.source});
}

// ---------------------------------------------------------------------------
// Mapper
// ---------------------------------------------------------------------------

/// Maps any caught exception to the correct [CaxiloFailure] subtype.
///
/// Idempotent: if [error] is already a [CaxiloFailure] it is returned as-is.
/// Repository catch blocks should call this instead of constructing failures
/// manually.
CaxiloFailure mapToCaxiloFailure(Object error) {
  // Already mapped — pass through.
  if (error is CaxiloFailure) return error;

  // In-house game specific exceptions.
  if (error is caxiloconfig.InHouseGameMaintenanceException) {
    return CaxiloMaintenanceFailure(source: error);
  }
  if (error is caxiloconfig.InHouseGameComingSoonException) {
    return CaxiloComingSoonFailure(source: error);
  }
  if (error is caxiloconfig.InHouseGameDisabledException) {
    return CaxiloDisabledFailure(source: error);
  }
  if (error is caxiloconfig.InHouseGameUnderDevelopmentException) {
    return CaxiloUnderDevelopmentFailure(source: error);
  }
  if (error is caxiloconfig.InHouseGameException) {
    // Any other in-house exception (e.g. url fetch) falls through to unknown.
    return CaxiloUnknownFailure(source: error);
  }

  // GameApiException — map by type enum.
  if (error is gac.GameApiException) {
    return switch (error.type) {
      gac.GameApiExceptionType.networkError ||
      gac.GameApiExceptionType.timeout => CaxiloNetworkFailure(source: error),
      gac.GameApiExceptionType.authenticationError ||
      gac.GameApiExceptionType.tokenRefreshError => CaxiloAuthFailure(source: error),
      gac.GameApiExceptionType.serverError => CaxiloServerFailure(
        message: error.message,
        source: error,
      ),
      gac.GameApiExceptionType.businessError || gac.GameApiExceptionType.clientError =>
        CaxiloBusinessFailure(message: error.message, source: error),
      _ => CaxiloUnknownFailure(message: error.message, source: error),
    };
  }

  return CaxiloUnknownFailure(source: error);
}
