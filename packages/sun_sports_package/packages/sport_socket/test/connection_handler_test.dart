import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';

void main() {
  group('Ping/Pong Protocol', () {
    test('ping message format is Base64 encoded ping_<number>', () {
      // Test the ping format as per V2 spec
      const pingNum = 42;
      final message = 'ping_$pingNum';
      final encoded = base64Encode(utf8.encode(message));

      // Verify encoding
      expect(encoded, isNotEmpty);

      // Verify decoding back
      final decoded = utf8.decode(base64Decode(encoded));
      expect(decoded, equals('ping_42'));
    });

    test('pong message can be parsed from plain text', () {
      const pongMessage = 'pong_42';

      // Parse pong number
      final number = int.tryParse(pongMessage.replaceFirst('pong_', ''));

      expect(number, equals(42));
    });

    test('pong message can be parsed from Base64', () {
      const originalPong = 'pong_123';
      final encodedPong = base64Encode(utf8.encode(originalPong));

      // Decode and parse
      final decoded = utf8.decode(base64Decode(encodedPong));
      final number = int.tryParse(decoded.replaceFirst('pong_', ''));

      expect(number, equals(123));
    });

    test('ping counter increments correctly', () {
      var pingCounter = 0;

      final ping1 = pingCounter++;
      final ping2 = pingCounter++;
      final ping3 = pingCounter++;

      expect(ping1, equals(0));
      expect(ping2, equals(1));
      expect(ping3, equals(2));
    });

    test('pong validation matches awaiting ping number', () {
      int? awaitingPongNumber;

      // Simulate sending ping_5
      awaitingPongNumber = 5;

      // Simulate receiving pong_5
      const pongMessage = 'pong_5';
      final receivedNumber =
          int.tryParse(pongMessage.replaceFirst('pong_', ''));

      final isMatch = receivedNumber == awaitingPongNumber;
      expect(isMatch, isTrue);

      // Wrong pong number should not match
      awaitingPongNumber = 10;
      final isWrongMatch = receivedNumber == awaitingPongNumber;
      expect(isWrongMatch, isFalse);
    });

    test('pong timeout triggers after duration', () async {
      final completer = Completer<bool>();
      const timeout = Duration(milliseconds: 50);

      // Start timeout timer
      Timer(timeout, () {
        completer.complete(true);
      });

      // Wait for timeout
      final timedOut = await completer.future;
      expect(timedOut, isTrue);
    });

    test('pong timeout can be cancelled', () async {
      var timeoutTriggered = false;
      const timeout = Duration(milliseconds: 100);

      // Start timeout timer
      final timer = Timer(timeout, () {
        timeoutTriggered = true;
      });

      // Cancel immediately
      timer.cancel();

      // Wait past the timeout duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Should not have triggered
      expect(timeoutTriggered, isFalse);
    });
  });

  group('Binary Message Handling', () {
    test('List<int> is recognized as binary data', () {
      dynamic message = [0x0a, 0x1b, 0x08, 0x01];

      final isBinary = message is List<int>;
      expect(isBinary, isTrue);
    });

    test('String is recognized as text data', () {
      dynamic message = 'pong_1';

      final isString = message is String;
      final isBinary = message is List<int>;

      expect(isString, isTrue);
      expect(isBinary, isFalse);
    });

    test('Base64 pong detection works correctly', () {
      // Plain pong
      const plainPong = 'pong_42';
      expect(plainPong.startsWith('pong_'), isTrue);

      // Encoded pong
      final encodedPong = base64Encode(utf8.encode('pong_42'));
      expect(encodedPong.startsWith('pong_'), isFalse);

      // But after decode
      final decoded = utf8.decode(base64Decode(encodedPong));
      expect(decoded.startsWith('pong_'), isTrue);
    });

    test('invalid Base64 throws and can be caught', () {
      const invalidBase64 = 'not-valid-base64!!!';

      String? decoded;
      try {
        decoded = utf8.decode(base64Decode(invalidBase64));
      } catch (_) {
        decoded = null;
      }

      expect(decoded, isNull);
    });
  });
}
