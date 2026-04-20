import 'dart:typed_data';

import '../proto/proto.dart';

/// Parser for converting raw binary WebSocket messages to Protobuf Payload objects.
///
/// The server sends raw Protobuf binary data (not Base64 encoded).
/// This parser handles the decoding and provides error handling for malformed messages.
class ProtoParser {
  /// Parse raw binary data into a [Payload] object.
  ///
  /// Returns `null` if parsing fails (malformed data, empty bytes, etc.)
  /// Errors are logged but not thrown to allow continued processing.
  Payload? parse(Uint8List bytes) {
    if (bytes.isEmpty) {
      return null;
    }

    try {
      return Payload.fromBuffer(bytes);
    } catch (e) {
      // Log error for debugging but don't throw
      // This allows the socket to continue processing other messages
      print('[ProtoParser] Failed to parse message: $e');
      return null;
    }
  }

  /// Parse with detailed error information for debugging.
  ///
  /// Returns a [ParseResult] containing either the parsed payload or error details.
  ParseResult parseWithDetails(Uint8List bytes) {
    if (bytes.isEmpty) {
      return ParseResult.error('Empty bytes received');
    }

    try {
      final payload = Payload.fromBuffer(bytes);
      return ParseResult.success(payload);
    } catch (e, stackTrace) {
      return ParseResult.error(
        'Failed to parse protobuf: $e',
        stackTrace: stackTrace,
        rawBytes: bytes,
      );
    }
  }
}

/// Result of parsing a protobuf message.
class ParseResult {
  final Payload? payload;
  final String? error;
  final StackTrace? stackTrace;
  final Uint8List? rawBytes;

  const ParseResult._({
    this.payload,
    this.error,
    this.stackTrace,
    this.rawBytes,
  });

  factory ParseResult.success(Payload payload) =>
      ParseResult._(payload: payload);

  factory ParseResult.error(
    String error, {
    StackTrace? stackTrace,
    Uint8List? rawBytes,
  }) =>
      ParseResult._(
        error: error,
        stackTrace: stackTrace,
        rawBytes: rawBytes,
      );

  bool get isSuccess => payload != null;
  bool get isError => error != null;
}
