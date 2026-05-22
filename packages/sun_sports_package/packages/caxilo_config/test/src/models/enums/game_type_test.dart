import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.GameType', () {
    test('fromJson returns correct enum for valid strings', () {
      expect(cc.GameType.fromJson('slot'), cc.GameType.slot);
      expect(cc.GameType.fromJson('card'), cc.GameType.card);
      expect(cc.GameType.fromJson('live'), cc.GameType.live);
      expect(cc.GameType.fromJson('minigame'), cc.GameType.miniGame);
      expect(cc.GameType.fromJson('fish'), cc.GameType.fishing);
      expect(cc.GameType.fromJson('others'), cc.GameType.others);
    });

    test('fromJson returns unknown for invalid strings', () {
      expect(cc.GameType.fromJson('invalid'), cc.GameType.unknown);
      expect(cc.GameType.fromJson(''), cc.GameType.unknown);
    });

    test('toJson returns correct string', () {
      expect(cc.GameType.slot.toJson(), 'slot');
      expect(cc.GameType.card.toJson(), 'card');
      expect(cc.GameType.miniGame.toJson(), 'miniGame');
      // Note: toJson uses name, so for fishing it returns 'fishing'
      // unless overridden by json_serializable mapping in a model.
      // In the enum itself, toJson() returns name.
      expect(cc.GameType.fishing.toJson(), 'fishing');
    });
  });
}
