import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

void main() {
  group('OrientationMismatchView', () {
    Widget buildTestableWidget({
      required OrientationPolicy policy,
      required double width,
      required double height,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, height)),
          child: OrientationMismatchView(policy: policy),
        ),
      );
    }

    testWidgets('shows "rotate" message for mobile devices', (tester) async {
      // Small screen = mobile
      await tester.pumpWidget(
        buildTestableWidget(
          policy: OrientationPolicy.landscape,
          width: 375, // iPhone-like width
          height: 667,
        ),
      );

      expect(find.text('Please rotate your device to landscape'), findsOneWidget);
    });

    testWidgets('shows "resize" message for large devices', (tester) async {
      // Large screen = desktop
      await tester.pumpWidget(
        buildTestableWidget(
          policy: OrientationPolicy.landscape,
          width: 2560,
          height: 1440,
        ),
      );

      expect(find.text('Please resize your window to landscape'), findsOneWidget);
    });

    testWidgets('shows portrait specific message', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          policy: OrientationPolicy.portrait,
          width: 1024, // Tablet width
          height: 768,
        ),
      );

      // Shortest side is 768, which is > 600 (tablet breakpoint).
      // canRotate is true for tablet.
      expect(find.text('Please rotate your device to portrait'), findsOneWidget);
    });

    testWidgets('shows resize portrait message for very large devices', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          policy: OrientationPolicy.portrait,
          width: 2560,
          height: 1600, // shortestSide = 1600 > 1300
        ),
      );

      expect(find.text('Please resize your window to portrait'), findsOneWidget);
    });
  });
}
