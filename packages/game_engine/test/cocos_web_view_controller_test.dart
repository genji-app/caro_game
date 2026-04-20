// import 'package:flutter_test/flutter_test.dart';
// import 'package:game_engine/game_engine.dart';
// import 'package:game_engine/src/in_house_runner/ih_runner_controller.dart';
// import 'package:game_engine/src/in_house_runner/mobile/ih_runner_controller_mobile.dart';

// void main() {
//   group('IHRunnerControllerMobile', () {
//     late IHRunnerControllerMobile controller;

//     setUp(() {
//       controller = IHRunnerControllerMobile();
//     });

//     tearDown(() {
//       controller.dispose();
//     });

//     test('initial state is idle', () {
//       expect(controller.loadState, IHRunnerLoadState.idle);
//       expect(controller.isLoading, isFalse);
//     });

//     test('updateLoadState updates state and emits to stream', () async {
//       final states = <IHRunnerLoadState>[];
//       controller.onLoadStateChanged.listen(states.add);

//       controller.updateLoadState(IHRunnerLoadState.loading);
//       expect(controller.loadState, IHRunnerLoadState.loading);
//       expect(controller.isLoading, isTrue);

//       controller.updateLoadState(IHRunnerLoadState.loaded);
//       expect(controller.loadState, IHRunnerLoadState.loaded);
//       expect(controller.isLoading, isFalse);

//       // Verify stream emissions
//       await Future<void>.delayed(Duration.zero);
//       expect(states, [IHRunnerLoadState.loading, IHRunnerLoadState.loaded]);
//     });

//     test('currentUrl updates along with load state', () {
//       const testUrl = 'https://example.com/game';
//       controller.updateLoadState(IHRunnerLoadState.loading, url: testUrl);
//       expect(controller.currentUrl, testUrl);
//     });

//     test('backToApp event is translated to EXIT_GAME', () async {
//       // Note: We can't easily trigger the JS handler in unit tests
//       // without mocking InAppWebViewController, which is complex.
//     });
//   });
// }
