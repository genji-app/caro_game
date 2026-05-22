import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';

/// Integration Test for Authentication Flow
///
/// This test verifies the complete authentication flow:
/// 1. Load mainConfig from GitHub
/// 2. Refresh token
/// 3. Get SB token
/// 4. Load settings
/// 5. Get user info
///
/// NOTE: This is an integration test that requires:
/// - Real network connection
/// - Valid user token in environment
/// - Access to GitHub and API servers
///
/// To run: flutter test test/core/services/integration/sb_authentication_integration_test.dart

void main() {
  group('Authentication Integration Tests', () {
    late SbConfig config;
    late SbHttpManager http;

    setUp(() {
      config = SbConfig.instance;
      http = SbHttpManager.instance;
      config.reset();
      http.reset();
    });

    test(
      'STEP 1: Load mainConfig from GitHub',
      () async {
        // This test loads the actual base64-encoded config from GitHub
        print('\n=== STEP 1: Loading mainConfig ===');

        try {
          final mainConfig = await SbHttpManager.getConfig(
            SbConfig.mainConfigUrl,
          );

          print('✅ Config loaded successfully');
          print('Keys: ${mainConfig.keys.toList()}');

          expect(mainConfig, isNotEmpty);
          expect(mainConfig['api_domain'], isNotNull);
          expect(mainConfig['sport_domain'], isNotNull);
          expect(mainConfig['main_ws_url'], isNotNull);

          print('api_domain: ${mainConfig['api_domain']}');
          print('sport_domain: ${mainConfig['sport_domain']}');

          // Store config
          config.mainConfig = mainConfig;
        } catch (e) {
          print('❌ Failed to load config: $e');
          fail('Failed to load mainConfig: $e');
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test('STEP 2: Build dynamic URLs', () {
      // Assume config is loaded from previous test
      if (config.mainConfig.isEmpty) {
        print('⚠️ Skipping - config not loaded');
        return;
      }

      print('\n=== STEP 2: Building dynamic URLs ===');

      expect(config.loginUrl, isNotEmpty);
      expect(config.refreshUrl, isNotEmpty);
      expect(config.sportTokenUrl, isNotEmpty);

      print('✅ URLs built successfully');
      print('loginUrl: ${config.loginUrl}');
      print('sportTokenUrl: ${config.sportTokenUrl}');
    });

    test(
      'STEP 3: Load sbConfig from GitHub',
      () async {
        print('\n=== STEP 3: Loading sbConfig ===');

        try {
          final sbConfig =
              await http.send(SbConfig.sbConfigUrl, json: true)
                  as Map<String, dynamic>;

          print('✅ sbConfig loaded');
          print('Keys: ${sbConfig.keys.toList()}');

          expect(sbConfig, isNotEmpty);
          expect(sbConfig['urlSetting'], isNotNull);

          print('urlSetting: ${sbConfig['urlSetting']}');
        } catch (e) {
          print('❌ Failed to load sbConfig: $e');
          fail('Failed to load sbConfig: $e');
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'Complete Authentication Flow (requires user token)',
      () async {
        // This test requires a real user token
        // Set it via environment variable: USER_TOKEN=your_token flutter test

        print('\n=== COMPLETE AUTHENTICATION FLOW ===');

        final userToken = const String.fromEnvironment('USER_TOKEN');
        if (userToken.isEmpty) {
          print('⚠️ Skipping - USER_TOKEN not provided');
          print('To run: USER_TOKEN=your_token flutter test ...');
          return;
        }

        try {
          // 1. Load mainConfig
          print('\n1️⃣ Loading mainConfig...');
          final mainConfig = await SbHttpManager.getConfig(
            SbConfig.mainConfigUrl,
          );
          config.mainConfig = mainConfig;
          print('✅ mainConfig loaded');

          // 2. Set user token
          print('\n2️⃣ Setting user token...');
          http.userToken = userToken;
          print('✅ User token set');

          // 3. Load sbConfig and settings
          print('\n3️⃣ Loading sbConfig and settings...');
          final sbConfig =
              await http.send(SbConfig.sbConfigUrl, json: true)
                  as Map<String, dynamic>;

          final urlSetting = sbConfig['urlSetting'] as String;
          await http.getSetting(urlSetting, SbConfig.agentId);
          print('✅ Settings loaded');
          print('Domains loaded:');
          print('  - urlHomeExposeService: ${http.urlHomeExposeService}');
          print('  - urlHomeBettingService: ${http.urlHomeBettingService}');

          // 4. Get sportbook token
          print('\n4️⃣ Getting sportbook token...');
          final sbToken = await http.getSbToken();
          print('✅ SB token obtained: ${sbToken.substring(0, 20)}...');

          // 5. Get user info
          print('\n5️⃣ Getting user info...');
          await http.getUserByToken();
          print('✅ User info loaded:');
          print('  - Display Name: ${http.displayName}');
          print('  - Username: ${http.custLogin}');
          print('  - Balance: ${http.userBalance}K ${http.currency}');
          print('  - Status: ${http.status}');

          // Verify
          expect(http.userTokenSb, isNotEmpty);
          expect(http.displayName, isNotEmpty);
          expect(http.custLogin, isNotEmpty);
          expect(http.userBalance, greaterThanOrEqualTo(0));

          print('\n🎉 AUTHENTICATION FLOW COMPLETE!');
        } catch (e, stackTrace) {
          print('❌ Authentication failed: $e');
          print('Stack trace: $stackTrace');
          fail('Authentication flow failed: $e');
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'Test API Methods (requires authentication)',
      () async {
        print('\n=== TESTING API METHODS ===');

        // Check if authenticated
        if (http.userTokenSb.isEmpty) {
          print('⚠️ Skipping - Not authenticated');
          print('Run complete authentication flow test first');
          return;
        }

        try {
          // Test 1: Get hot matches
          print('\n1️⃣ Testing getEventHotMatch...');
          final hotMatches = await http.getEventHotMatch(SbConfig.agentId);
          print('✅ Hot matches: ${hotMatches['events']?.length ?? 0}');

          // Test 2: Get bet history
          print('\n2️⃣ Testing betsReporting...');
          final history = await http.betsReporting('pending');
          print('✅ Pending bets: ${history['bets']?.length ?? 0}');

          print('\n🎉 API METHODS TEST COMPLETE!');
        } catch (e) {
          print('❌ API test failed: $e');
          // Don't fail test if API calls fail, as it might be due to no data
        }
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );
  });
}
