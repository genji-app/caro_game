import 'package:freezed_annotation/freezed_annotation.dart';

/// Supported screen orientations for a casino game.
enum GameOrientation {
  /// Portrait (vertical) orientation, upright.
  portraitUp,

  /// Portrait (vertical) orientation, upside down.
  portraitDown,

  /// Landscape (horizontal) orientation, tilted left.
  landscapeLeft,

  /// Landscape (horizontal) orientation, tilted right.
  landscapeRight;

  /// Whether this orientation is a portrait variant.
  bool get isPortrait => this == portraitUp || this == portraitDown;

  /// Whether this orientation is a landscape variant.
  bool get isLandscape => this == landscapeLeft || this == landscapeRight;

  /// Helper for both portrait orientations.
  static const portrait = [portraitUp, portraitDown];

  /// Helper for both landscape orientations.
  static const landscape = [landscapeLeft, landscapeRight];

  /// Helper for all orientations.
  static const all = [portraitUp, landscapeLeft, portraitDown, landscapeRight];

  /// Parses an orientation string or alias.
  static List<GameOrientation> fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'portrait':
        return portrait;
      case 'landscape':
        return landscape;
      case 'portraitup':
        return [portraitUp];
      case 'portraitdown':
        return [portraitDown];
      case 'landscapeleft':
        return [landscapeLeft];
      case 'landscaperight':
        return [landscapeRight];
      case 'all':
        return all;
      default:
        return const [];
    }
  }

  /// Parses a string into a [GameOrientation] (single value fallback).
  /// Returns [GameOrientation.portraitUp] if the value is not recognized.
  static GameOrientation fromJson(String value) => GameOrientation.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GameOrientation.portraitUp,
  );

  /// Converts the enum to a string for JSON serialization.
  String toJson() => name;
}

/// Converter for [List<GameOrientation>] to support aliases in JSON.
class GameOrientationListConverter implements JsonConverter<List<GameOrientation>, List<dynamic>?> {
  const GameOrientationListConverter();

  @override
  List<GameOrientation> fromJson(List<dynamic>? json) {
    if (json == null) return const [];
    final result = <GameOrientation>{};
    for (final item in json) {
      if (item is String) {
        result.addAll(GameOrientation.fromString(item));
      }
    }
    return result.toList();
  }

  @override
  List<dynamic> toJson(List<GameOrientation> object) {
    return object.map((e) => e.name).toList();
  }
}
