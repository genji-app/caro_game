/// Base exception class for all [CaxiloConfigClient] related errors.
sealed class CaxiloConfigException implements Exception {
  /// Constructor for [CaxiloConfigException].
  const CaxiloConfigException(this.message);

  /// Error description message.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the configuration JSON fails to be parsed.
class CaxiloConfigParseException extends CaxiloConfigException {
  /// Constructor for [CaxiloConfigParseException].
  const CaxiloConfigParseException(super.message);
}

/// Thrown when the remote configuration cannot be fetched.
class CaxiloConfigFetchException extends CaxiloConfigException {
  /// Constructor for [CaxiloConfigFetchException].
  const CaxiloConfigFetchException(super.message);
}

/// Thrown when a required game or configuration is missing.
class CaxiloConfigNotFoundException extends CaxiloConfigException {
  /// Constructor for [CaxiloConfigNotFoundException].
  const CaxiloConfigNotFoundException(super.message);
}

/// Base exception class for all game related errors.
sealed class InHouseGameException extends CaxiloConfigException {
  const InHouseGameException(super.message);
}

/// Exception thrown when an in-house game is requested but its
/// entry point (URL) has not been implemented yet.
class InHouseGameUnderDevelopmentException extends InHouseGameException {
  /// Constructor for [InHouseGameUnderDevelopmentException].
  const InHouseGameUnderDevelopmentException() : super('Game is not ready.');
}

/// Exception thrown when an in-house game is under maintenance.
class InHouseGameMaintenanceException extends InHouseGameException {
  /// Constructor for [InHouseGameMaintenanceException].
  const InHouseGameMaintenanceException() : super('Game is under maintenance.');
}

/// Exception thrown when an in-house game is coming soon.
class InHouseGameComingSoonException extends InHouseGameException {
  /// Constructor for [InHouseGameComingSoonException].
  const InHouseGameComingSoonException() : super('Game is coming soon.');
}

/// Exception thrown when an in-house game is disabled.
class InHouseGameDisabledException extends InHouseGameException {
  /// Constructor for [InHouseGameDisabledException].
  const InHouseGameDisabledException() : super('Game is disabled.');
}

/// Exception thrown when the URL for an in-house game could
/// not be retrieved.
class InHouseGameUrlFetchException extends InHouseGameException {
  /// Constructor for [InHouseGameUrlFetchException].
  const InHouseGameUrlFetchException(super.message);
}
