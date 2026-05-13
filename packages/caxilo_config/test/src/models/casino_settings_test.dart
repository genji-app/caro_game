import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.CaxiloConfig', () {
    const mockJson = {
      'updated_at': '2026-04-21T10:00:00Z',
      'version': 3,
      'environments': {'avenger_base_url': 'https://avenger.live'},
      'display': {
        'order': ['AVENGER'],
      },
      'categories': [
        {
          'id': 'sunwin',
          'translation_key': 'key',
          'icon': 'icon',
          'icon_active': 'icon_active',
          'filter': {'strategy': 'in_house'},
        },
      ],
      'lobby': {
        'sections': [
          {
            'title': 'Featured Games',
            'filter': {
              'strategy': 'by_game_type',
              'params': {'game_type': 'slot'},
            },
            'limit': 10,
          },
        ],
      },
      'in_house': {
        'catalog': [
          {
            'product_id': 'sunwin_AVENGER',
            'game_code': 'AVENGER',
            'game_name': 'Avenger',
            'provider_id': 'sunwin',
            'provider_name': 'Sunwin',
            'image': 'img.webp',
            'lang': 'vi',
            'game_type': 'slot',
            'launch_strategy': 'standard',
          },
        ],
        'visibility': {
          'AVENGER': {'is_visible': true, 'status': 'active'},
        },
      },
    };

    test('fromJson creates correct instance of root config', () {
      final config = cc.CaxiloConfig.fromJson(mockJson);

      expect(config.version, 3);
      expect(config.updatedAt, '2026-04-21T10:00:00Z');
      expect(config.environments['avenger_base_url'], 'https://avenger.live');
      expect(config.display.order.first, 'AVENGER');
      expect(config.categories.length, 1);
      expect(config.categories.first.id, 'sunwin');
      expect(config.categories.first.filter.strategy, cc.CaxiloFilterStrategy.inHouse);
      expect(config.lobby?.sections.length, 1);
      expect(config.lobby?.sections.first.displayTitle, 'Featured Games');
      expect(config.lobby?.sections.first.filter?.strategy, cc.CaxiloFilterStrategy.byGameType);
      expect(config.inHouse.catalog.length, 1);
      expect(config.inHouse.catalog.first.gameCode, 'AVENGER');
      expect(config.inHouse.visibility['AVENGER']?.isVisible, true);
    });

    test('toJson returns correct nested map', () {
      final config = cc.CaxiloConfig.fromJson(mockJson);
      final json = config.toJson();

      expect(json['version'], 3);
      expect(json['display']['order'][0], 'AVENGER');
      expect(json['lobby']['sections'][0]['title'], 'Featured Games');
      expect(json['in_house']['catalog'][0]['game_code'], 'AVENGER');
      expect(json['in_house']['visibility']['AVENGER']['is_visible'], true);
    });

    test('uses default values for missing nested sections', () {
      const minimalJson = {'updated_at': '2026-04-21T10:00:00Z'};

      final config = cc.CaxiloConfig.fromJson(minimalJson);
      expect(config.version, 1);
      expect(config.environments, isEmpty);
      expect(config.inHouse.catalog, isEmpty);
    });
  });
}
