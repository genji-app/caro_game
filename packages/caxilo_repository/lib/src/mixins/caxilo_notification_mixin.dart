import 'dart:async';

import '../models/models.dart';

/// {@template caxilo_event}
/// Events emitted by the repository to notify listeners of state changes.
/// {@endtemplate}
sealed class CaxiloEvent {
  /// {@macro caxilo_event}
  const CaxiloEvent();
}

/// {@template caxilo_data_changed}
/// Emitted when the game cache is refreshed with new data
/// (e.g., after a remote API fetch completes).
/// {@endtemplate}
class CaxiloDataChanged extends CaxiloEvent {
  /// {@macro caxilo_data_changed}
  const CaxiloDataChanged(this.games);

  /// The updated list of all games (local + remote).
  final List<CaxiloGameBlock> games;
}

/// Mixin responsible for managing and broadcasting repository events.
///
/// This mixin encapsulates the [StreamController] and provides a public [events]
/// stream for external observers. It also provides internal methods to emit events.
mixin CaxiloNotificationMixin {
  /// Broadcast controller for repository events.
  final _eventController = StreamController<CaxiloEvent>.broadcast();

  /// Stream of repository events (data changes, errors, etc.).
  ///
  /// Emits [CaxiloDataChanged] whenever the cache is refreshed with new data.
  /// UI providers should watch this to stay in sync.
  Stream<CaxiloEvent> get events => _eventController.stream;

  /// Emits a [CaxiloEvent] to all listeners.
  void emitEvent(CaxiloEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// Closes the event stream.
  ///
  /// Should be called during the repository's disposal.
  void disposeNotifications() {
    _eventController.close();
  }
}
