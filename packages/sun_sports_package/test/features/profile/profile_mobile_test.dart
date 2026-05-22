// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sun_sports/features/profile/presentation/widgets/profile_mobile_bottom_sheet.dart';
// import 'package:sun_sports/features/profile/presentation/widgets/profile_mobile_header.dart';

// void main() {
//   group('ProfileMobileBottomSheet', () {
//     testWidgets('renders without errors', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             home: Scaffold(
//               body: Builder(
//                 builder: (context) => ElevatedButton(
//                   onPressed: () {
//                     ProfileMobileBottomSheet.show(context);
//                   },
//                   child: const Text('Open Profile'),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );

//       // Find and tap the button
//       await tester.tap(find.text('Open Profile'));
//       await tester.pumpAndSettle();

//       // Verify the bottom sheet is displayed
//       expect(find.text('Thông tin User'), findsOneWidget);
//       expect(find.text('Ví'), findsOneWidget);
//       expect(find.text('Tài khoản'), findsOneWidget);
//       expect(find.text('Thoát'), findsWidgets); // May find multiple due to InnerShadowCard
//     });

//     testWidgets('closes when backdrop is tapped', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             home: Scaffold(
//               body: Builder(
//                 builder: (context) => ElevatedButton(
//                   onPressed: () {
//                     ProfileMobileBottomSheet.show(context);
//                   },
//                   child: const Text('Open Profile'),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );

//       // Open the bottom sheet
//       await tester.tap(find.text('Open Profile'));
//       await tester.pumpAndSettle();

//       // Verify it's open
//       expect(find.text('Thông tin User'), findsOneWidget);

//       // Tap outside to close (tap on the barrier)
//       await tester.tapAt(const Offset(10, 10));
//       await tester.pumpAndSettle();

//       // Verify it's closed
//       expect(find.text('Thông tin User'), findsNothing);
//     });
//   });

//   group('ProfileMobileHeader', () {
//     testWidgets('renders correctly', (tester) async {
//       var closeCalled = false;

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: ProfileMobileHeader(
//               onClose: () {
//                 closeCalled = true;
//               },
//             ),
//           ),
//         ),
//       );

//       // Verify header elements
//       expect(find.text('Thông tin User'), findsOneWidget);
//       expect(find.byIcon(Icons.close), findsOneWidget);

//       // Tap close button
//       await tester.tap(find.byIcon(Icons.close));
//       await tester.pump();

//       // Verify callback was called
//       expect(closeCalled, isTrue);
//     });
//   });

//   group('Profile Mobile UI Responsiveness', () {
//     testWidgets('renders on small screen (iPhone SE)', (tester) async {
//       // Set screen size to iPhone SE (375x667) - logical pixels
//       tester.view.physicalSize = const Size(750, 1334);
//       tester.view.devicePixelRatio = 2.0;
//       addTearDown(tester.view.resetPhysicalSize);
//       addTearDown(tester.view.resetDevicePixelRatio);

//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             home: Scaffold(
//               body: Builder(
//                 builder: (context) => ElevatedButton(
//                   onPressed: () {
//                     ProfileMobileBottomSheet.show(context);
//                   },
//                   child: const Text('Open Profile'),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );

//       // Open the bottom sheet
//       await tester.tap(find.text('Open Profile'));
//       await tester.pumpAndSettle();

//       // Verify content is visible (overflow is acceptable in scrollable content)
//       expect(find.text('Thông tin User'), findsOneWidget);
//       expect(find.text('Ví'), findsOneWidget);
//       expect(find.text('Tài khoản'), findsOneWidget);
//     });

//     testWidgets('renders on large screen (iPhone 14 Pro Max)', (tester) async {
//       // Set screen size to iPhone 14 Pro Max (430x932) - logical pixels
//       tester.view.physicalSize = const Size(1290, 2796);
//       tester.view.devicePixelRatio = 3.0;
//       addTearDown(tester.view.resetPhysicalSize);
//       addTearDown(tester.view.resetDevicePixelRatio);

//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             home: Scaffold(
//               body: Builder(
//                 builder: (context) => ElevatedButton(
//                   onPressed: () {
//                     ProfileMobileBottomSheet.show(context);
//                   },
//                   child: const Text('Open Profile'),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );

//       // Open the bottom sheet
//       await tester.tap(find.text('Open Profile'));
//       await tester.pumpAndSettle();

//       // Verify content is visible
//       expect(find.text('Thông tin User'), findsOneWidget);
//       expect(find.text('Ví'), findsOneWidget);
//       expect(find.text('Tài khoản'), findsOneWidget);
//     });
//   });
// }
