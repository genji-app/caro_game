import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.GameLaunchStrategy', () {
    test('fromJson returns correct strategy for valid strings', () {
      expect(cc.GameLaunchStrategy.fromJson('standard'), cc.GameLaunchStrategy.standard);
      expect(cc.GameLaunchStrategy.fromJson('fish'), cc.GameLaunchStrategy.fish);
      expect(
        cc.GameLaunchStrategy.fromJson('underDevelopment'),
        cc.GameLaunchStrategy.underDevelopment,
      );
    });

    test('fromJson returns unknown for invalid strings', () {
      expect(cc.GameLaunchStrategy.fromJson('invalid'), cc.GameLaunchStrategy.unknown);
    });

    test('toJson returns the enum name', () {
      expect(cc.GameLaunchStrategy.standard.toJson(), 'standard');
      expect(cc.GameLaunchStrategy.underDevelopment.toJson(), 'underDevelopment');
    });
  });
}
