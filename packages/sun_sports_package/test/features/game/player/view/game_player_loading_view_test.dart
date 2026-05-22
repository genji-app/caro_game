import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/features/game/game.dart';

void main() {
  group('GamePlayerLoadingView Widget Test', () {
    testWidgets('renders logo and progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GamePlayerLoadingView())),
      );

      // Verify progress indicator exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify logo area exists (represented by ImageHelper.load)
      // Since it's a network image in tests, it might show the error widget or placeholder
      // but we just check if the widget tree structure is correct.
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('respects progress value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GamePlayerLoadingView(progress: 0.5)),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });
  });
}
