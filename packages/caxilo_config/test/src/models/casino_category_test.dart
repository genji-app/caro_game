import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.CategoryConfig', () {
    test('fromJson - valid data', () {
      final json = {
        'id': 'slots',
        'translation_key': 'key_slots',
        'icon': 'icon.svg',
        'icon_active': 'icon_active.svg',
        'filter': {
          'strategy': 'by_game_type',
          'params': {'game_type': 'slot'},
        },
      };
      final category = cc.CategoryConfig.fromJson(json);

      expect(category.id, 'slots');
      expect(category.translationKey, 'key_slots');
      expect(category.icon, 'icon.svg');
      expect(category.iconActive, 'icon_active.svg');
      expect(category.filter.strategy, cc.CaxiloFilterStrategy.byGameType);
      expect(category.filter.params?['game_type'], 'slot');
    });

    test('fromJson - inHouse strategy', () {
      final json = {
        'id': 'sunwin',
        'translation_key': 'key_sunwin',
        'icon': 'icon.png',
        'icon_active': 'icon_active.png',
        'filter': {'strategy': 'in_house'},
      };
      final category = cc.CategoryConfig.fromJson(json);

      expect(category.id, 'sunwin');
      expect(category.filter.strategy, cc.CaxiloFilterStrategy.inHouse);
    });

    test('fromJson - unknown strategy (fallback behavior)', () {
      final json = {
        'id': 'unknown_test',
        'translation_key': 'key_unknown',
        'icon': 'icon.svg',
        'icon_active': 'icon_active.svg',
        'filter': {
          'strategy': 'future_strategy_99',
          'params': {'some': 'data'},
        },
      };
      final category = cc.CategoryConfig.fromJson(json);

      // Strategy không khớp sẽ fallback về unknown
      expect(category.filter.strategy, cc.CaxiloFilterStrategy.unknown);
    });
  });
}
