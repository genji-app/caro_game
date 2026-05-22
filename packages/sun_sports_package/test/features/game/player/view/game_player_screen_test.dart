// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/orientation/app_orientation_provider.dart';

class MockGamePlayerNotifier extends StateNotifier<GamePlayerState>
    with Mock
    implements GamePlayerNotifier {
  MockGamePlayerNotifier() : super(const GamePlayerState.initial());

  final _eventsController = StreamController<GamePlayerEvent>.broadcast();

  // Provide a real controller so _GameWebViewLayer can pass it to GameRunnerView.
  @override
  final GameRunnerController runnerController = GameRunnerController();

  @override
  Stream<GamePlayerEvent> get events => _eventsController.stream;

  void emitExit() => _eventsController.add(const GamePlayerExitEvent());

  @override
  void dispose() {
    runnerController.dispose();
    _eventsController.close();
    super.dispose();
  }
}

class MockOrientationController extends Mock implements OrientationController {}

class FakeOrientationController extends Fake implements OrientationController {}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeOrientationPolicy extends Fake implements OrientationPolicy {}

class FakePlatformInAppWebViewWidgetCreationParams extends Fake
    implements PlatformInAppWebViewWidgetCreationParams {}

class MockInAppWebViewPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements InAppWebViewPlatform {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return MockPlatformInAppWebViewWidget(params);
  }
}

class MockPlatformInAppWebViewWidget extends Mock
    with MockPlatformInterfaceMixin
    implements PlatformInAppWebViewWidget {
  MockPlatformInAppWebViewWidget(this.params);
  @override
  final PlatformInAppWebViewWidgetCreationParams params;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {}

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();
}

void main() {
  late MockGamePlayerNotifier mockNotifier;
  late MockOrientationController mockOrientationController;

  const game = GameBlock.inHouse(
    providerId: 'provider-1',
    providerName: 'Provider 1',
    image: 'image.png',
    productId: 'product-1',
    gameCode: 'game-1',
    gameName: 'Test Game',
    lang: 'vi',
    gameType: GameType.slot,
  );

  setUpAll(() {
    registerFallbackValue(Orientation.portrait);
    registerFallbackValue(FakeOrientationController());
    registerFallbackValue(FakeRoute());
    registerFallbackValue(FakeOrientationPolicy());
    registerFallbackValue(FakePlatformInAppWebViewWidgetCreationParams());

    // Mock InAppWebView platform
    final mockPlatform = MockInAppWebViewPlatform();
    InAppWebViewPlatform.instance = mockPlatform;
  });

  setUp(() {
    mockNotifier = MockGamePlayerNotifier();
    mockOrientationController = MockOrientationController();

    // Default mock behavior for initialization
    when(
      () => mockNotifier.initializePlayer(
        orientationController: any(named: 'orientationController'),
        previousPolicy: any(named: 'previousPolicy'),
        gamePolicy: any(named: 'gamePolicy'),
        isMobileLogin: any(named: 'isMobileLogin'),
      ),
    ).thenAnswer((_) async {});

    // Mock orientation controller behaviors
    when(() => mockOrientationController.apply(any())).thenAnswer(
      (_) async => OrientationApplyResult.matched(OrientationPolicy.landscape),
    );
    when(() => mockOrientationController.restore(any())).thenAnswer(
      (_) async => OrientationApplyResult.matched(OrientationPolicy.portrait),
    );

    // Mock isMatched to avoid TypeError 'Null' is not a subtype of 'bool'
    when(
      () => mockOrientationController.isMatched(
        policy: any(named: 'policy'),
        currentOrientation: any(named: 'currentOrientation'),
      ),
    ).thenReturn(true);

    // Mock isApplying and activePolicy to avoid Null errors
    when(() => mockOrientationController.isApplying).thenReturn(false);
    when(() => mockOrientationController.activePolicy).thenReturn(null);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        gamePlayerProvider(game).overrideWith((ref) => mockNotifier),
        orientationControllerProvider.overrideWithValue(
          mockOrientationController,
        ),
      ],
      child: MaterialApp(
        home: OrientationScope(
          controller: mockOrientationController,
          child: const GamePlayerScreen(game: game),
        ),
      ),
    );
  }

  testWidgets(
    'GamePlayerScreen shows loading overlay during settingUp/connecting',
    (tester) async {
      mockNotifier.state = const GamePlayerState.loading(
        stage: GamePlayerLoadingStage.settingUp,
      );

      await tester.pumpWidget(createTestWidget());

      // Loading should be visible
      expect(find.byType(GamePlayerLoadingView), findsOneWidget);

      mockNotifier.state = const GamePlayerState.loading(
        stage: GamePlayerLoadingStage.connecting,
      );
      await tester.pump();
      expect(find.byType(GamePlayerLoadingView), findsOneWidget);
    },
  );

  testWidgets('GamePlayerScreen shows error overlay on failure', (
    tester,
  ) async {
    mockNotifier.state = const GamePlayerState.failure(
      failureType: GamePlayerErrorType.network,
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(GamePlayerFailureView), findsOneWidget);
    expect(find.text('Không có kết nối mạng'), findsOneWidget);
  });

  testWidgets('GamePlayerScreen shows loading overlay during exiting', (
    tester,
  ) async {
    mockNotifier.state = const GamePlayerState.exiting();

    await tester.pumpWidget(createTestWidget());

    // In our implementation, exiting also shows the loading overlay immediately
    expect(find.byType(GamePlayerLoadingView), findsOneWidget);
  });

  testWidgets('GamePlayerScreen pops when ExitEvent is received', (
    tester,
  ) async {
    mockNotifier.state = const GamePlayerState.playing(
      gameUrl: 'https://example.com',
      showWebView: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gamePlayerProvider(game).overrideWith((ref) => mockNotifier),
          orientationControllerProvider.overrideWithValue(
            mockOrientationController,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrientationScope(
                        controller: mockOrientationController,
                        child: const GamePlayerScreen(game: game),
                      ),
                    ),
                  ),
                  child: const Text('Go'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Go to screen. Avoid pumpAndSettle due to potential infinite animations in Loading.
    await tester.tap(find.text('Go'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GamePlayerScreen), findsOneWidget);

    // Trigger event
    mockNotifier.emitExit();

    // Process stream and microtasks.
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(GamePlayerScreen), findsNothing);
    expect(find.text('Go'), findsOneWidget);
  });

  testWidgets('GamePlayerScreen handles mismatch debounce logic', (
    tester,
  ) async {
    // Set state to playing so mismatch overlay is allowed to show
    mockNotifier.state = const GamePlayerState.playing(
      gameUrl: 'https://game.com',
      showWebView: true,
    );

    await tester.pumpWidget(createTestWidget());

    // Initially not mismatched
    expect(find.byKey(const ValueKey('mismatch-overlay')), findsNothing);

    // Simulate mismatch
    final dynamic state = tester.state(find.byType(GamePlayerScreen));
    state.handleMismatch(true);

    // Should not show immediately (debounce 1s)
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('mismatch-overlay')), findsNothing);

    // Should show after 1s
    await tester.pump(const Duration(milliseconds: 501));
    await tester.pump(); // Ensure rebuild after Timer
    expect(find.byKey(const ValueKey('mismatch-overlay')), findsOneWidget);

    // Simulate match
    state.handleMismatch(false);

    // Should hide immediately
    await tester.pump();
    expect(find.byKey(const ValueKey('mismatch-overlay')), findsNothing);
  }, skip: !kIsWeb);
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
