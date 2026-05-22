import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaxiloCategory', () {
    const game = CaxiloGameBlock.inHouse(
      providerId: 'pragmatic',
      providerName: 'Pragmatic',
      image: 'img.png',
      productId: 'P1',
      gameCode: 'G1',
      gameName: 'Game 1',
      lang: 'en',
      gameType: GameType.slot,
    );

    test('matches correctly using internal filter', () {
      final category = CaxiloCategory(
        categoryId: 'slots',
        translationKey: 'txt_slots',
        filter: CaxiloFilter.byGameTypes(gameTypes: [GameType.slot]),
      );

      expect(category.matches(game), isTrue);

      final liveGame = game.copyWith(gameType: GameType.live);
      expect(category.matches(liveGame), isFalse);
    });

    test('id returns categoryId', () {
      const category = CaxiloCategory(
        categoryId: 'custom_id',
        translationKey: 'key',
        filter: CaxiloFilter.all(filters: []),
      );

      expect(category.id, equals('custom_id'));
    });

    test('getIcon returns correct icon based on active state', () {
      const category = CaxiloCategory(
        categoryId: 'id',
        translationKey: 'key',
        filter: CaxiloFilter.all(filters: []),
        icon: 'normal.png',
        iconActive: 'active.png',
      );

      expect(category.getIcon(active: false), equals('normal.png'));
      expect(category.getIcon(active: true), equals('active.png'));
    });
  });
}
