import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.InHouseGame', () {
    const mockJson = {
      'product_id': 'sunwin_AVENGER',
      'game_code': 'AVENGER',
      'game_name': 'Avenger',
      'provider_id': 'sunwin',
      'provider_name': 'Sunwin',
      'image': 'thumb.webp',
      'lang': 'vi',
      'game_type': 'slot',
      'launch_strategy': 'standard',
      'base_url_key': 'avenger_base_url',
      'mobile_login': true,
      'enable_host_message': true,
      'game_id': 123,
    };

    test('fromJson creates correct instance', () {
      final config = cc.InHouseGame.fromJson(mockJson);

      expect(config.productId, 'sunwin_AVENGER');
      expect(config.gameCode, 'AVENGER');
      expect(config.gameType, cc.GameType.slot);
      expect(config.launchStrategy, cc.GameLaunchStrategy.standard);
      expect(config.gameId, 123);
      expect(config.mobileOrientation, cc.GameOrientation.landscape);
    });

    test('toJson returns correct map', () {
      final config = cc.InHouseGame.fromJson(mockJson);
      final json = config.toJson();

      expect(json['product_id'], 'sunwin_AVENGER');
      expect(json['game_type'], 'slot');
      expect(json['game_id'], 123);
    });

    test('supports value equality', () {
      final config1 = cc.InHouseGame.fromJson(mockJson);
      final config2 = cc.InHouseGame.fromJson(mockJson);

      expect(config1, equals(config2));
    });

    test('uses default orientation if not provided', () {
      final jsonWithNoOrientation = Map<String, dynamic>.from(mockJson);
      jsonWithNoOrientation.remove('mobile_orientation');

      final config = cc.InHouseGame.fromJson(jsonWithNoOrientation);
      expect(config.mobileOrientation, cc.GameOrientation.landscape);
    });
  });
}
