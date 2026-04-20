import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';

void main() {
  group('GameHostEvent', () {
    test('fromJson parses typed JSON string correctly', () {
      const raw = '{"type": "EXIT_GAME", "data": {"score": 10}, "source": "game"}';
      final ev = GameHostEvent.fromJson(raw);

      expect(ev.type, 'EXIT_GAME');
      expect(ev.data['score'], 10);
      expect(ev.source, 'game');
      expect(ev.raw, raw);
    });

    test('fromJson handles plain string for legacy games (backToApp)', () {
      const raw = 'backToApp';
      final ev = GameHostEvent.fromJson(raw);

      expect(ev.type, 'backToApp');
      expect(ev.data, isEmpty);
      expect(ev.source, isNull);
      expect(ev.raw, raw);
    });

    test('fromJson parses Map input correctly', () {
      final input = {
        'type': 'ROUND_END',
        'data': {'win': true},
        'source': 'flutter'
      };
      final ev = GameHostEvent.fromJson(input);

      expect(ev.type, 'ROUND_END');
      expect(ev.data['win'], isTrue);
      expect(ev.source, 'flutter');
    });

    test('encode/roundtrip is consistent', () {
      const ev = GameHostEvent(
        type: 'CUSTOM_EVENT',
        data: {'p': 1},
        source: 'host',
      );
      final encoded = ev.encode();
      final decoded = GameHostEvent.fromJson(encoded);

      expect(decoded.type, ev.type);
      expect(decoded.data, ev.data);
      expect(decoded.source, ev.source);
    });

    test('toJson excludes source when null', () {
      const ev = GameHostEvent(type: 'PING');
      final json = ev.toJson();
      expect(json, isNot(contains('source')));
      expect(json['type'], 'PING');
    });

    test('fromJson handles invalid JSON gracefully by returning empty event', () {
      const raw = '{ invalid';
      final ev = GameHostEvent.fromJson(raw);
      expect(ev.type, isEmpty);
      expect(ev.data, isEmpty);
    });

    test('fromJson handles missing required fields cleanly', () {
      const raw = '{"data": {}}';
      final ev = GameHostEvent.fromJson(raw);
      expect(ev.type, isEmpty);
    });

    test('fromJson with source extraction', () {
      const raw = '{"type": "EXIT", "source": "IHRunnerEngine"}';
      final ev = GameHostEvent.fromJson(raw);
      expect(ev.type, 'EXIT');
      expect(ev.source, 'IHRunnerEngine');
    });
  });
}
