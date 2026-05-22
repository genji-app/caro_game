import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

void main() {
  testWidgets('ResponsiveBuilder resolves device types by width', (
    tester,
  ) async {
    DeviceType? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(500, 800)),
          child: ResponsiveBuilder(
            builder: (context, type) {
              captured = type;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(captured, DeviceType.mobile);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(950, 800)),
          child: ResponsiveBuilder(
            builder: (context, type) {
              captured = type;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(captured, DeviceType.tablet);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1300, 800)),
          child: ResponsiveBuilder(
            builder: (context, type) {
              captured = type;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(captured, DeviceType.desktop);
  });
}
