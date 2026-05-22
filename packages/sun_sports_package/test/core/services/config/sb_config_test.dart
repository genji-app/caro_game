import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';

void main() {
  group('SbConfig Tests', () {
    late SbConfig config;

    setUp(() {
      config = SbConfig.instance;
      // Reset config before each test
      config.reset();
    });

    test('should be singleton', () {
      final instance1 = SbConfig.instance;
      final instance2 = SbConfig();
      final instance3 = SbConfig.instance;

      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
    });

    test('should have correct hardcoded URLs', () {
      expect(SbConfig.mainConfigUrl, contains('githubusercontent.com'));
      expect(SbConfig.mainConfigUrl, contains('creator_s_prod.json'));
      expect(SbConfig.sbConfigUrl, contains('sb.json'));
    });

    test('should have correct constants', () {
      expect(SbConfig.agentId, equals(32));
      expect(SbConfig.clientId, equals('sun'));
      expect(SbConfig.brandId, equals('sun'));
      expect(SbConfig.chatZone, equals('Simms'));
      expect(SbConfig.chatRoom, equals('sb'));
    });

    test('should have correct localStorage keys', () {
      expect(SbConfig.userTokenKey, equals('user_token'));
      expect(SbConfig.refreshTokenKey, equals('refresh_token'));
    });

    test('should return URLs with empty domain when mainConfig is empty', () {
      // When mainConfig is empty, getters still build URLs but with empty domains
      expect(config.loginUrl, equals('id?command=loginAccessToken'));
      expect(
        config.refreshUrl,
        equals('id?command=refreshToken&refreshToken='),
      );
      expect(config.sportTokenUrl, equals('?command=get-token'));
      // WebSocket URLs return empty string to prevent invalid URL connection
      expect(config.mainWs, isEmpty);
      expect(config.chatWs, isEmpty);
      expect(config.sportDomainTop, isEmpty);
      expect(config.avatarUrl, isEmpty);
      expect(config.logo, isEmpty);
    });

    test('should build correct dynamic URLs when mainConfig is loaded', () {
      // Simulate loaded config
      config.mainConfig = {
        'api_domain': 'https://api.test.com/',
        'sport_domain': 'https://sport.test.com/',
        'sport_domain_top': 'https://top.test.com/',
        'main_ws_url': 'wss://ws.test.com',
        'ws_sport_domain': 'wss://sport-ws.test.com',
        'avatarUrl': 'https://cdn.test.com/avatars/',
        'logo': 'test.logo',
      };
      config.wsToken = 'test_ws_token';

      expect(
        config.loginUrl,
        equals('https://api.test.com/id?command=loginAccessToken'),
      );
      expect(
        config.refreshUrl,
        equals('https://api.test.com/id?command=refreshToken&refreshToken='),
      );
      expect(
        config.sportTokenUrl,
        equals('https://sport.test.com/?command=get-token'),
      );
      expect(config.mainWs, equals('wss://ws.test.com?token=test_ws_token'));
      expect(
        config.chatWs,
        equals('wss://sport-ws.test.com?token=test_ws_token'),
      );
      expect(config.sportDomainTop, equals('https://top.test.com/'));
      expect(config.avatarUrl, equals('https://cdn.test.com/avatars/'));
      expect(config.logo, equals('test.logo'));
    });

    test('should check if config is loaded', () {
      expect(config.isConfigLoaded, isFalse);

      config.mainConfig = {'api_domain': 'https://test.com/'};
      expect(config.isConfigLoaded, isTrue);
    });

    test('should reset config correctly', () {
      // Setup
      config.mainConfig = {'api_domain': 'https://test.com/'};
      config.wsToken = 'test_token';

      expect(config.isConfigLoaded, isTrue);
      expect(config.wsToken, isNotEmpty);

      // Reset
      config.reset();

      expect(config.isConfigLoaded, isFalse);
      expect(config.wsToken, isEmpty);
    });

    test('should generate full avatar URL', () {
      config.mainConfig = {'avatarUrl': 'https://cdn.test.com/avatars/'};

      expect(
        config.getAvatarUrl('user123.jpg'),
        equals('https://cdn.test.com/avatars/user123.jpg'),
      );

      expect(config.getAvatarUrl(''), isEmpty);
    });

    test('should return empty avatar URL when avatarUrl not configured', () {
      expect(config.getAvatarUrl('user123.jpg'), isEmpty);
    });

    test('should have correct toString representation', () {
      final str = config.toString();
      expect(str, contains('SbConfig'));
      expect(str, contains('isConfigLoaded'));
      expect(str, contains('wsToken'));
      expect(str, contains('useMockData'));
    });

    test('should toggle debug mode', () {
      expect(config.isDebugMode, isFalse);
      expect(config.useMockData, isFalse);

      config.isDebugMode = true;
      config.useMockData = true;

      expect(config.isDebugMode, isTrue);
      expect(config.useMockData, isTrue);
    });
  });
}
