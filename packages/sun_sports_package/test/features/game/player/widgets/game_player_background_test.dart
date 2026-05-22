import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/features/game/player/widgets/game_player_background.dart';

void main() {
  group('GamePlayerBackground Widget Test', () {
    testWidgets('renders child on top of background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GamePlayerBackground(
              child: Text('Overlay Content'),
            ),
          ),
        ),
      );

      expect(find.text('Overlay Content'), findsOneWidget);
      expect(find.descendant(
        of: find.byType(GamePlayerBackground),
        matching: find.byType(Stack),
      ), findsOneWidget);
    });
  });
}
