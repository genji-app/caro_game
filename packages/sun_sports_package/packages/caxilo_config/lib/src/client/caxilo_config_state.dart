import 'caxilo_config_exceptions.dart';

/// Represents the loading state of the caxilo config configuration.
sealed class CaxiloConfigStatus {
  const CaxiloConfigStatus();

  /// Initial state before any loading attempt.
  const factory CaxiloConfigStatus.initial() = CaxiloConfigStatusInitial;

  /// Currently fetching the configuration from a remote or local source.
  const factory CaxiloConfigStatus.loading() = CaxiloConfigStatusLoading;

  /// Configuration successfully loaded.
  const factory CaxiloConfigStatus.loaded() = CaxiloConfigStatusLoaded;

  /// Failed to load the configuration.
  const factory CaxiloConfigStatus.failure(CaxiloConfigException error) = CaxiloConfigStatusFailure;
}

/// Initial state of caxilo config.
final class CaxiloConfigStatusInitial extends CaxiloConfigStatus {
  const CaxiloConfigStatusInitial();
}

/// Loading state of caxilo config.
final class CaxiloConfigStatusLoading extends CaxiloConfigStatus {
  const CaxiloConfigStatusLoading();
}

/// Success state of caxilo config.
final class CaxiloConfigStatusLoaded extends CaxiloConfigStatus {
  const CaxiloConfigStatusLoaded();
}

/// Failure state of caxilo config.
final class CaxiloConfigStatusFailure extends CaxiloConfigStatus {
  const CaxiloConfigStatusFailure(this.failure);

  /// The exception that occurred during loading.
  final CaxiloConfigException failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaxiloConfigStatusFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
