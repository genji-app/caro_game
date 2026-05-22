import 'dart:convert';

import 'package:test/test.dart';
import 'package:sport_socket/src/client/v2_subscription_helper.dart';

void main() {
  group('V2SubscriptionHelper', () {
    group('Channel Building', () {
      test('builds league channel correctly', () {
        final channel = V2SubscriptionHelper.leagueChannel(1);
        expect(channel, equals('ln:vi:s:1:l'));
      });

      test('builds league channel with custom language', () {
        final channel = V2SubscriptionHelper.leagueChannel(1, lang: 'en');
        expect(channel, equals('ln:en:s:1:l'));
      });

      test('builds match channel correctly', () {
        final channel = V2SubscriptionHelper.matchChannel(1, 0);
        expect(channel, equals('ln:vi:s:1:tr:0:e'));
      });

      test('builds match channel with time range', () {
        // Live
        expect(V2SubscriptionHelper.matchChannel(1, V2TimeRange.live),
            equals('ln:vi:s:1:tr:0:e'));
        // Today
        expect(V2SubscriptionHelper.matchChannel(1, V2TimeRange.today),
            equals('ln:vi:s:1:tr:1:e'));
        // Early
        expect(V2SubscriptionHelper.matchChannel(1, V2TimeRange.early),
            equals('ln:vi:s:1:tr:2:e'));
      });

      test('builds combat sport match channel with sportTypeId', () {
        final channel = V2SubscriptionHelper.matchChannel(
          3, // Combat sport
          1, // Today
          sportTypeId: CombatSportType.muayThai,
        );
        expect(channel, equals('ln:vi:s:3:st:1:tr:1:e'));
      });

      test('builds match detail channel correctly', () {
        final channel = V2SubscriptionHelper.matchDetailChannel(12345);
        expect(channel, equals('ln:vi:e:12345'));
      });

      test('builds hot channel correctly', () {
        final channel = V2SubscriptionHelper.hotChannel(1);
        expect(channel, equals('ln:vi:s:1:e:hot'));
      });

      test('builds outright channel correctly', () {
        final channel = V2SubscriptionHelper.outrightChannel(1);
        expect(channel, equals('ln:vi:s:1:e:ort'));
      });
    });

    group('Message Building', () {
      test('builds subscribe message as binary (raw UTF-8 bytes)', () {
        final bytes = V2SubscriptionHelper.subscribeMessage('ln:vi:s:1:l');
        // NO Base64 - just raw UTF-8 bytes
        final decoded = utf8.decode(bytes);
        expect(decoded, equals('SUBSCRIBE:ln:vi:s:1:l'));
      });

      test('builds unsubscribe message as binary (raw UTF-8 bytes)', () {
        final bytes = V2SubscriptionHelper.unsubscribeMessage('ln:vi:s:1:l');
        // NO Base64 - just raw UTF-8 bytes
        final decoded = utf8.decode(bytes);
        expect(decoded, equals('UNSUBSCRIBE:ln:vi:s:1:l'));
      });

      test('builds ping message as binary (raw UTF-8 bytes)', () {
        final bytes = V2SubscriptionHelper.pingMessage(42);
        // Ping is NOT Base64 encoded - just raw UTF-8 bytes
        final decoded = utf8.decode(bytes);
        expect(decoded, equals('ping_42'));
      });
    });

    group('Channel Parsing', () {
      test('parses sportId from league channel', () {
        expect(V2SubscriptionHelper.parseSportId('ln:vi:s:1:l'), equals(1));
        expect(V2SubscriptionHelper.parseSportId('ln:vi:s:42:l'), equals(42));
      });

      test('parses sportId from match channel', () {
        expect(
            V2SubscriptionHelper.parseSportId('ln:vi:s:1:tr:0:e'), equals(1));
      });

      test('parses timeRange from match channel', () {
        expect(
            V2SubscriptionHelper.parseTimeRange('ln:vi:s:1:tr:0:e'), equals(0));
        expect(
            V2SubscriptionHelper.parseTimeRange('ln:vi:s:1:tr:1:e'), equals(1));
        expect(
            V2SubscriptionHelper.parseTimeRange('ln:vi:s:1:tr:2:e'), equals(2));
      });

      test('parses eventId from match detail channel', () {
        expect(
            V2SubscriptionHelper.parseEventId('ln:vi:e:12345'), equals(12345));
      });

      test('returns null for invalid channel formats', () {
        expect(V2SubscriptionHelper.parseSportId('invalid'), isNull);
        expect(V2SubscriptionHelper.parseTimeRange('ln:vi:s:1:l'), isNull);
        expect(V2SubscriptionHelper.parseEventId('ln:vi:s:1:l'), isNull);
      });
    });

    group('Channel Type Detection', () {
      test('detects league channel', () {
        expect(V2SubscriptionHelper.isLeagueChannel('ln:vi:s:1:l'), isTrue);
        expect(V2SubscriptionHelper.isLeagueChannel('ln:en:s:42:l'), isTrue);
        expect(
            V2SubscriptionHelper.isLeagueChannel('ln:vi:s:1:tr:0:e'), isFalse);
      });

      test('detects match channel', () {
        expect(V2SubscriptionHelper.isMatchChannel('ln:vi:s:1:tr:0:e'), isTrue);
        expect(V2SubscriptionHelper.isMatchChannel('ln:vi:s:1:l'), isFalse);
      });

      test('detects match detail channel', () {
        expect(
            V2SubscriptionHelper.isMatchDetailChannel('ln:vi:e:12345'), isTrue);
        expect(V2SubscriptionHelper.isMatchDetailChannel('ln:vi:e:hot'),
            isFalse); // This is hot channel
      });

      test('detects hot channel', () {
        expect(V2SubscriptionHelper.isHotChannel('ln:vi:s:1:e:hot'), isTrue);
        expect(V2SubscriptionHelper.isHotChannel('ln:vi:s:1:e:ort'), isFalse);
      });

      test('detects outright channel', () {
        expect(
            V2SubscriptionHelper.isOutrightChannel('ln:vi:s:1:e:ort'), isTrue);
        expect(
            V2SubscriptionHelper.isOutrightChannel('ln:vi:s:1:e:hot'), isFalse);
      });
    });
  });

  group('V2TimeRange', () {
    test('converts string to int correctly', () {
      expect(V2TimeRange.fromString('LIVE'), equals(0));
      expect(V2TimeRange.fromString('TODAY'), equals(1));
      expect(V2TimeRange.fromString('EARLY'), equals(2));
      expect(V2TimeRange.fromString('live'), equals(0)); // Case insensitive
      expect(V2TimeRange.fromString('unknown'), equals(0)); // Default to LIVE
    });

    test('converts int to string correctly', () {
      expect(V2TimeRange.toStringValue(0), equals('LIVE'));
      expect(V2TimeRange.toStringValue(1), equals('TODAY'));
      expect(V2TimeRange.toStringValue(2), equals('EARLY'));
      expect(V2TimeRange.toStringValue(99), equals('LIVE')); // Default
    });
  });

  group('CombatSportType', () {
    test('has correct values', () {
      expect(CombatSportType.muayThai, equals(1));
      expect(CombatSportType.mma, equals(2));
      expect(CombatSportType.boxing, equals(3));
    });
  });
}
