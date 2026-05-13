import 'package:caxilo_repository/src/supported_games_whitelist.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupportedGamesWhitelist', () {
    test('isSupported returns true for all in test mode', () {
      final whitelist = SupportedGamesWhitelist(testMode: true);
      expect(whitelist.isSupported(providerId: 'any', gameCode: 'any'), isTrue);
    });

    test('isSupported filters correctly in production mode', () {
      final whitelist = SupportedGamesWhitelist(testMode: false);

      // Known supported game
      expect(whitelist.isSupported(providerId: 'amb-vn', gameCode: 'mx-live-001'), isTrue);

      // Unknown game from known provider
      expect(whitelist.isSupported(providerId: 'amb-vn', gameCode: 'unknown'), isFalse);

      // Unknown provider
      expect(whitelist.isSupported(providerId: 'unknown', gameCode: 'any'), isFalse);
    });

    test('normalization works', () {
      final whitelist = SupportedGamesWhitelist(testMode: false);
      expect(whitelist.isSupported(providerId: ' AMB-vn ', gameCode: ' MX-LIVE-001 '), isTrue);
    });
  });
}
