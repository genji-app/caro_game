import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders mobile or desktop layout', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(500, 800)),
            child: HomeScreen(),
          ),
        ),
      ),
    );
    expect(find.text('Home (Mobile)'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1400, 900)),
            child: HomeScreen(),
          ),
        ),
      ),
    );
    expect(find.text('Home (Desktop)'), findsOneWidget);
  });
}
