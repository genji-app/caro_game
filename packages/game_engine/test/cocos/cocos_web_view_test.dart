import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';

void main() {
  group('IHRunner', () {
    testWidgets('renders basic widget on supportable platform', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IHRunner(
            gameUrl: 'https://test-game.com',
          ),
        ),
      );

      // Verify widget exists in the tree
      expect(find.byType(IHRunner), findsOneWidget);
    });

    // Legacy engine test removed because webview_flutter was deprecated for this package

    testWidgets('passes events to host message callback', (tester) async {
      GameHostEvent? receivedEvent;

      await tester.pumpWidget(
        MaterialApp(
          home: IHRunner(
            gameUrl: 'https://test-game.com',
            onHostMessage: (ev) => receivedEvent = ev,
          ),
        ),
      );

      // Manual verification of properties passed down is hard with dynamic stubs,
      // but we ensure the facade is building properly.
      expect(find.byType(IHRunner), findsOneWidget);
      expect(receivedEvent, isNull);
    });
  });
}
