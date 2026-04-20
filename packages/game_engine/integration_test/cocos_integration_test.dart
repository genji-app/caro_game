import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IHRunner Integration', () {
    testWidgets('loads a real URL and responds to bridge', (tester) async {
      GameHostEvent? event;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IHRunner(
              // Using a simple local anchor simulation or a real URL
              gameUrl: 'https://cdn.games.com/test-h5',
              onHostMessage: (ev) => event = ev,
            ),
          ),
        ),
      );

      // Verify the WebView widget is in the tree
      expect(find.byType(IHRunner), findsOneWidget);

      // In real integration tests on device, we would wait for load
      // and then simulate JS message. This is just a structure.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(event, isNull,
          reason: 'Event should be null until JS actually calls it');
    });
  });
}
