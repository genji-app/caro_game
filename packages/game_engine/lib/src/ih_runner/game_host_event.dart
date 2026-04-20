import 'dart:convert';

/// {@template game_host_event}
/// A standard message envelope for the [IHRunner] Host Bridge protocol.
///
/// This model represents bidirection events between the game runtime (JS)
/// and the Flutter engine.
/// {@endtemplate}
class GameHostEvent {
  /// Initializes [GameHostEvent].
  const GameHostEvent({
    required this.type,
    this.data = const {},
    this.source,
    this.raw,
  });

  /// Parses a [GameHostEvent] from a raw bridge payload.
  ///
  /// [input] can be:
  /// - A `Map<String, dynamic>` decoded from JSON.
  /// - A `String` (legacy events that send just the type as a plain string,
  ///   or modern typed JSON strings).
  factory GameHostEvent.fromJson(dynamic input) {
    if (input == null) return const GameHostEvent(type: '');

    if (input is Map) {
      final map = input.cast<String, dynamic>();
      return GameHostEvent(
        type: map['type'] as String? ?? '',
        data: (map['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
        source: map['source'] as String?,
        raw: map['raw'] as String? ?? jsonEncode(map),
      );
    }

    final rawStr = input.toString().trim();

    // 1. If it looks like a JSON object, try parsing it
    if (rawStr.startsWith('{')) {
      try {
        final decoded = jsonDecode(rawStr);
        if (decoded is Map) {
          final map = decoded.cast<String, dynamic>();
          return GameHostEvent(
            type: map['type'] as String? ?? '',
            data: (map['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
            source: map['source'] as String?,
            raw: rawStr, // ✅ PRESERVE original raw string for tests/diagnostics
          );
        }
      } catch (_) {
        // If it looks like JSON but is malformed, return empty as per spec
        return const GameHostEvent(type: '');
      }
    }

    // 2. Fallback: simple string payload (legacy game format)
    return GameHostEvent(type: rawStr, raw: rawStr);
  }

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// The discriminating event type key (e.g. `'closeWebView'`, `'ROUND_END'`).
  final String type;

  /// Arbitrary key-value payload delivered with the event.
  final Map<String, dynamic> data;

  /// Identifies the message origin (e.g. `'ih_runner-game'`, `'flutter-host'`).
  final String? source;

  /// The raw string payload as received from the bridge (for diagnostics).
  final String? raw;

  // ---------------------------------------------------------------------------
  // Getters & Utils
  // ---------------------------------------------------------------------------

  /// Shorthand to determine if the game has requested to exit the WebView.
  ///
  /// Matches standard types like `'closeWebView'`, `'EXIT_GAME'`, etc.
  bool get isCloseWebView {
    final t = type.toLowerCase();
    return t == 'closewebview' || t == 'exit_game' || t == 'backtoapp';
  }

  /// Converts this event to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        if (source != null) 'source': source,
      };

  /// Encodes this event to a JSON string (for sending to the game).
  String encode() => jsonEncode(toJson());

  // ---------------------------------------------------------------------------
  // Overrides
  // ---------------------------------------------------------------------------

  @override
  String toString() => 'GameHostEvent(type: $type, data: $data, source: $source)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHostEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          data.toString() == other.data.toString() &&
          source == other.source;

  @override
  int get hashCode => type.hashCode ^ data.hashCode ^ source.hashCode;
}
