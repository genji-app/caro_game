import 'dart:convert';

import 'message_key.dart';
import '../utils/constants.dart';
import '../utils/result.dart';
import '../utils/logger.dart';

/// Batch JSON parser for WebSocket messages.
///
/// This is Layer 3 of the processing pipeline.
/// Parses JSON from raw messages that have already been sorted by priority.
class BatchParser {
  final Logger _logger;

  BatchParser({Logger? logger}) : _logger = logger ?? const NoOpLogger();

  /// Parse a batch of extracted keys into parsed messages.
  /// Returns list of successfully parsed messages.
  /// Failed parses are logged but don't stop processing.
  List<ParsedMessage> parseBatch(List<ExtractedKey> keys) {
    final results = <ParsedMessage>[];

    for (final key in keys) {
      final result = parseOne(key);
      result.whenSuccess((msg) => results.add(msg));
    }

    return results;
  }

  /// Parse a single message
  Result<ParsedMessage, ParseError> parseOne(ExtractedKey key) {
    try {
      final json = jsonDecode(key.raw) as Map<String, dynamic>;

      // Extract sport ID (s field)
      final sportId = _parseInt(json['s']) ?? 0;

      // Extract data payload (d field)
      final data = json['d'] as Map<String, dynamic>? ?? {};

      return Success(ParsedMessage(
        type: key.type,
        sportId: sportId,
        data: data,
        raw: key.raw,
        timestamp: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to parse message: ${key.type}',
        e,
        stackTrace,
      );
      return Failure(ParseError(key.raw, e.toString()));
    }
  }

  /// Parse odds_up message which may contain kafkaOddsList array
  List<ParsedMessage> parseOddsUp(ExtractedKey key) {
    try {
      final json = jsonDecode(key.raw) as Map<String, dynamic>;
      final sportId = _parseInt(json['s']) ?? 0;
      final data = json['d'] as Map<String, dynamic>? ?? {};

      // Check for kafkaOddsList array
      final oddsList = data['kafkaOddsList'] as List<dynamic>?;
      if (oddsList == null || oddsList.isEmpty) {
        // Single odds in data
        return [
          ParsedMessage(
            type: key.type,
            sportId: sportId,
            data: data,
            raw: key.raw,
            timestamp: DateTime.now(),
          ),
        ];
      }

      // Multiple odds - create separate message for each
      final results = <ParsedMessage>[];
      for (final oddsItem in oddsList) {
        if (oddsItem is Map<String, dynamic>) {
          results.add(ParsedMessage(
            type: key.type,
            sportId: sportId,
            data: oddsItem,
            raw: key.raw,
            timestamp: DateTime.now(),
          ));
        }
      }

      return results;
    } catch (e, stackTrace) {
      _logger.warning(
          'Failed to parse odds_up: ${e.toString()}', e, stackTrace);
      return [];
    }
  }

  /// Parse with expanded odds list handling
  List<ParsedMessage> parseWithOddsExpansion(List<ExtractedKey> keys) {
    final results = <ParsedMessage>[];

    for (final key in keys) {
      if (key.isBatch &&
          (key.type == MessageType.oddsUpdate ||
              key.type == MessageType.oddsInsert)) {
        // Expand odds batch into individual messages
        results.addAll(parseOddsUp(key));
      } else {
        // Normal parsing
        final result = parseOne(key);
        result.whenSuccess((msg) => results.add(msg));
      }
    }

    return results;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
