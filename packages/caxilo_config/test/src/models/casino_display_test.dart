import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cc.DisplayConfig', () {
    const mockJson = {
      'order': ['G1', 'G2'],
      'collections': {
        'featured': ['G1'],
        'new': ['G2'],
        'popular': ['G1'],
      },
    };

    test('fromJson creates correct instance', () {
      final display = cc.DisplayConfig.fromJson(mockJson);

      expect(display.order, ['G1', 'G2']);
      expect(display.collections['featured'], ['G1']);
      expect(display.collections['new'], ['G2']);
      expect(display.collections['popular'], ['G1']);
    });

    test('toJson returns correct map', () {
      final display = cc.DisplayConfig.fromJson(mockJson);
      final json = display.toJson();

      expect(json['order'], ['G1', 'G2']);
      expect(json['collections']['featured'], ['G1']);
      expect(json['collections']['new'], ['G2']);
    });

    test('defaults to empty lists and map', () {
      final display = cc.DisplayConfig.fromJson({});
      expect(display.order, isEmpty);
      expect(display.collections, isEmpty);
    });
  });
}
