import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/features/game/game.dart';

class MockCaxiloRepository extends Mock implements CaxiloRepository {}

class MockGameSessionGuard extends Mock implements GameSessionGuard {}

class MockOrientationController extends Mock implements OrientationController {}

void main() {
  late MockCaxiloRepository repository;
  late MockGameSessionGuard sessionGuard;
  late MockOrientationController orientationController;
  late GameBlock game;
  late GamePlayerNotifier notifier;

  const gamePolicy = OrientationPolicy.landscape;
  const previousPolicy = OrientationPolicy.portrait;

  setUpAll(() {
    registerFallbackValue(OrientationPolicy.portrait);
  });

  setUp(() {
    repository = MockCaxiloRepository();
    sessionGuard = MockGameSessionGuard();
    orientationController = MockOrientationController();

    game = const GameBlock.inHouse(
      providerId: 'provider-1',
      providerName: 'Provider 1',
      image: 'image.png',
      productId: 'product-1',
      gameCode: 'game-1',
      gameName: 'Test Game',
      lang: 'vi',
      gameType: GameType.slot,
    );

    // Default mock behaviors
    when(
      () => orientationController.apply(any()),
    ).thenAnswer((_) async => OrientationApplyResult.matched(gamePolicy));
    when(
      () => orientationController.restore(any()),
    ).thenAnswer((_) async => OrientationApplyResult.matched(previousPolicy));

    when(
      () => repository.getGameUrl(
        providerId: any(named: 'providerId'),
        productId: any(named: 'productId'),
        gameCode: any(named: 'gameCode'),
        lang: any(named: 'lang'),
        isMobileLogin: any(named: 'isMobileLogin'),
      ),
    ).thenAnswer((_) async => 'https://example.com/game');

    notifier = GamePlayerNotifier(
      game: game,
      repository: repository,
      sessionGuard: sessionGuard,
    );
  });

  group('GamePlayerNotifier - Initialization', () {
    test('initializePlayer completes full success flow', () async {
      final future = notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      // Should be in loading state with settingUp stage initially
      expect(
        notifier.state.maybeMap(
          loading: (s) => s.stage == GamePlayerLoadingStage.settingUp,
          orElse: () => false,
        ),
        isTrue,
      );

      await future;

      // Verify orientation was applied
      verify(() => orientationController.apply(gamePolicy)).called(1);

      // Verify URL was fetched
      verify(
        () => repository.getGameUrl(
          providerId: 'provider-1',
          productId: 'product-1',
          gameCode: 'game-1',
          lang: 'vi',
        ),
      ).called(1);

      // Should be in loading state with connecting stage
      notifier.state.mapOrNull(
        loading: (s) {
          expect(s.stage, GamePlayerLoadingStage.connecting);
          expect(s.gameUrl, 'https://example.com/game');
        },
      );
    });

    test(
      'initializePlayer waits for session guard cooldown if required',
      () async {
        game = const GameBlock.liveStream(
          providerId: 'provider-1',
          providerName: 'Provider 1',
          image: 'image.png',
          productId: 'product-1',
          gameCode: 'game-1',
          gameName: 'Test Game',
          lang: 'vi',
          gameType: GameType.live,
          lobbyUrl: '',
          cashierUrl: '',
          requiresSessionGuard: true,
        );

        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        when(
          () => sessionGuard.remainingCooldown(any()),
        ).thenReturn(const Duration(milliseconds: 100));
        when(() => sessionGuard.onSessionStarted(any())).thenReturn(null);

        final startTime = DateTime.now();
        await notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );
        final endTime = DateTime.now();

        expect(
          endTime.difference(startTime).inMilliseconds,
          greaterThanOrEqualTo(100),
        );
        verify(() => sessionGuard.onSessionStarted('provider-1')).called(1);
      },
    );

    test(
      'Orientation fail + best-effort (strictOrientationApply=false)',
      () async {
        when(
          () => orientationController.apply(any()),
        ).thenThrow(Exception('Device error'));

        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
          strictOrientationApply: false,
        );

        await notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );

        // Should not be in failure state
        expect(notifier.state, isNot(isA<GamePlayerFailureState>()));

        verify(() => orientationController.apply(gamePolicy)).called(1);
        verify(
          () => repository.getGameUrl(
            providerId: any(named: 'providerId'),
            productId: any(named: 'productId'),
            gameCode: any(named: 'gameCode'),
            lang: any(named: 'lang'),
            isMobileLogin: any(named: 'isMobileLogin'),
          ),
        ).called(1);
      },
    );

    test('Orientation fail + strict (strictOrientationApply=true)', () async {
      when(
        () => orientationController.apply(any()),
      ).thenThrow(Exception('Device error'));

      notifier = GamePlayerNotifier(
        game: game,
        repository: repository,
        sessionGuard: sessionGuard,
        strictOrientationApply: true,
      );

      await notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.isRetryable, isFalse);
          expect(s.failureType, GamePlayerErrorType.orientationSetupFailed);
        },
      );

      verifyNever(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      );
    });

    test('Session guard fail -> không block game load', () async {
      game = const GameBlock.liveStream(
        providerId: 'provider-1',
        providerName: 'Provider 1',
        image: 'image.png',
        productId: 'product-1',
        gameCode: 'game-1',
        gameName: 'Test Game',
        lang: 'vi',
        gameType: GameType.live,
        lobbyUrl: '',
        cashierUrl: '',
        requiresSessionGuard: true,
      );

      notifier = GamePlayerNotifier(
        game: game,
        repository: repository,
        sessionGuard: sessionGuard,
      );

      when(
        () => sessionGuard.remainingCooldown(any()),
      ).thenThrow(Exception('Guard error'));

      await notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      expect(notifier.state, isNot(isA<GamePlayerFailureState>()));

      verify(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).called(1);
    });
  });

  group('GamePlayerNotifier - Exit Flow', () {
    test('requestExit performs smooth transition and emits event', () async {
      await notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      final exitReceived = Completer<bool>();
      notifier.events.listen((event) {
        if (event is GamePlayerExitEvent) exitReceived.complete(true);
      });

      final future = notifier.requestExit();

      expect(notifier.state, isA<GamePlayerExitingState>());

      await future;

      // Verify orientation was restored
      verify(() => orientationController.restore(previousPolicy)).called(1);

      // Verify event was emitted
      expect(
        await exitReceived.future.timeout(const Duration(seconds: 2)),
        isTrue,
      );
    });

    test('requestExit is idempotent and prevents double-calls', () async {
      await notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      final f1 = notifier.requestExit();
      final f2 = notifier.requestExit();

      await Future.wait([f1, f2]);

      verify(() => orientationController.restore(any())).called(1);
    });
  });

  group('GamePlayerNotifier - WebView Lifecycle', () {
    test('onLoadStart transitions to loading stage', () {
      notifier.runnerController.add(const RunnerLoadStarted());
      expect(
        notifier.state.maybeMap(
          loading: (s) => s.stage == GamePlayerLoadingStage.loadingAssets,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('onLoadStop transitions to playing after delay', () async {
      // 1. Initialize to get a gameUrl
      await notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      notifier.runnerController.add(const RunnerLoadStarted());
      notifier.runnerController.add(const RunnerLoadStopped());

      // Should still be loadingAssets stage because of finishLoadDelay
      expect(
        notifier.state.maybeMap(
          loading: (s) => s.stage == GamePlayerLoadingStage.loadingAssets,
          orElse: () => false,
        ),
        isTrue,
      );

      // Wait for finishLoadDelay (777ms)
      await Future<void>.delayed(const Duration(milliseconds: 900));

      expect(notifier.state, isA<GamePlayerPlayingState>());
      expect(
        notifier.state.maybeMap(
          playing: (s) => s.showWebView,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('handleError transitions to error state', () {
      const errorMsg = 'Failed to load';
      notifier.runnerController.add(
        const RunnerErrorOccurred(message: errorMsg),
      );

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureMessage, errorMsg);
        },
      );
    });
  });

  group('GamePlayerNotifier - Edge Cases', () {
    test('onLoadStart should be ignored if already in playing stage', () {
      fakeAsync((async) {
        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );
        async.flushMicrotasks();
        async.elapse(
          const Duration(milliseconds: 500),
        ); // wait for cinematic delay

        notifier.runnerController.add(const RunnerLoadStarted());
        notifier.runnerController.add(const RunnerLoadStopped());
        async.elapse(
          const Duration(milliseconds: 900),
        ); // wait for finish load delay

        expect(notifier.state, isA<GamePlayerPlayingState>());

        notifier.runnerController.add(
          const RunnerLoadStarted(),
        ); // Should be ignored
        expect(notifier.state, isA<GamePlayerPlayingState>());
      });
    });

    test('onLoadStart should be ignored if finishLoadTimer is active', () {
      fakeAsync((async) {
        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 500));

        notifier.runnerController.add(const RunnerLoadStarted());
        notifier.runnerController.add(const RunnerLoadStopped());

        // Timer is active, not yet playing
        notifier.runnerController.add(
          const RunnerLoadStarted(),
        ); // Should be ignored
        expect(notifier.state, isA<GamePlayerLoadingState>());
      });
    });

    test('onLoadStop should be ignored if already in playing stage', () {
      fakeAsync((async) {
        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 500));

        notifier.runnerController.add(const RunnerLoadStarted());
        notifier.runnerController.add(const RunnerLoadStopped());
        async.elapse(const Duration(milliseconds: 900));

        expect(notifier.state, isA<GamePlayerPlayingState>());

        notifier.runnerController.add(
          const RunnerLoadStopped(),
        ); // Should be ignored
        expect(notifier.state, isA<GamePlayerPlayingState>());
      });
    });

    test(
      'onLoadStop should be ignored if finishLoadTimer is already active',
      () {
        fakeAsync((async) {
          notifier = GamePlayerNotifier(
            game: game,
            repository: repository,
            sessionGuard: sessionGuard,
          );

          notifier.initializePlayer(
            orientationController: orientationController,
            previousPolicy: previousPolicy,
            gamePolicy: gamePolicy,
          );
          async.flushMicrotasks();
          async.elapse(const Duration(milliseconds: 500));

          notifier.runnerController.add(const RunnerLoadStarted());
          notifier.runnerController.add(
            const RunnerLoadStopped(),
          ); // starts timer

          notifier.runnerController.add(
            const RunnerLoadStopped(),
          ); // Should not crash or restart timer
          expect(notifier.state, isA<GamePlayerLoadingState>());
        });
      },
    );

    test('onLoadStop should transition to error state if gameUrl is null', () {
      fakeAsync((async) {
        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        // We do not initializePlayer, so gameUrl is null
        notifier.runnerController.add(const RunnerLoadStarted());
        notifier.runnerController.add(const RunnerLoadStopped());

        async.elapse(const Duration(milliseconds: 900));

        expect(notifier.state, isA<GamePlayerFailureState>());
        notifier.state.mapOrNull(
          failure: (s) {
            expect(s.failureType, GamePlayerErrorType.missingGameUrl);
          },
        );
      });
    });

    test('Timeout timer should trigger loadTimeout failure', () {
      fakeAsync((async) {
        notifier = GamePlayerNotifier(
          game: game,
          repository: repository,
          sessionGuard: sessionGuard,
        );

        notifier.initializePlayer(
          orientationController: orientationController,
          previousPolicy: previousPolicy,
          gamePolicy: gamePolicy,
        );
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 500));

        notifier.runnerController.add(const RunnerLoadStarted());

        // Wait for 30s timeout
        async.elapse(const Duration(seconds: 30));

        expect(notifier.state, isA<GamePlayerFailureState>());
        notifier.state.mapOrNull(
          failure: (s) {
            expect(s.failureType, GamePlayerErrorType.loadTimeout);
          },
        );
      });
    });
  });

  group('GamePlayerNotifier - Error Handling', () {
    test('loadGameUrl handles CaxiloFailure correctly', () async {
      when(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).thenThrow(const CaxiloNetworkFailure());

      await notifier.loadGameUrl();

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureType, GamePlayerErrorType.network);
        },
      );
    });

    test('_applyFailureState — serverError preserves API message', () async {
      when(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).thenThrow(const CaxiloServerFailure(message: 'DB timeout'));

      await notifier.loadGameUrl();

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureType, GamePlayerErrorType.serverError);
          expect(s.failureMessage, equals('DB timeout'));
        },
      );
    });

    test('_applyFailureState — businessError preserves API message', () async {
      when(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).thenThrow(const CaxiloBusinessFailure(message: 'Tài khoản bị khóa'));

      await notifier.loadGameUrl();

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureType, GamePlayerErrorType.unknown);
          expect(s.failureMessage, equals('Tài khoản bị khóa'));
        },
      );
    });

    test('_applyFailureState — unknownError preserves message', () async {
      when(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).thenThrow(const CaxiloUnknownFailure(message: 'Parse error'));

      await notifier.loadGameUrl();

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureMessage, equals('Parse error'));
        },
      );
    });

    test('_applyFailureState — networkFailure message is null', () async {
      when(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).thenThrow(const CaxiloNetworkFailure());

      await notifier.loadGameUrl();

      expect(notifier.state, isA<GamePlayerFailureState>());
      notifier.state.mapOrNull(
        failure: (s) {
          expect(s.failureMessage, isNull);
        },
      );
    });

    test(
      '_applyFailureState — không kế thừa message từ failure trước',
      () async {
        // Step 1: Business failure
        when(
          () => repository.getGameUrl(
            providerId: any(named: 'providerId'),
            productId: any(named: 'productId'),
            gameCode: any(named: 'gameCode'),
            lang: any(named: 'lang'),
            isMobileLogin: any(named: 'isMobileLogin'),
          ),
        ).thenThrow(const CaxiloBusinessFailure(message: 'Lỗi cũ'));

        await notifier.loadGameUrl();
        expect(notifier.state.failureMessage, equals('Lỗi cũ'));

        // Step 2: Server failure
        when(
          () => repository.getGameUrl(
            providerId: any(named: 'providerId'),
            productId: any(named: 'productId'),
            gameCode: any(named: 'gameCode'),
            lang: any(named: 'lang'),
            isMobileLogin: any(named: 'isMobileLogin'),
          ),
        ).thenThrow(const CaxiloServerFailure(message: 'Lỗi mới'));

        await notifier.loadGameUrl();
        expect(notifier.state.failureMessage, equals('Lỗi mới'));
      },
    );

    test('retry increments retryCount and re-fetches URL', () async {
      notifier.retry();
      expect(
        notifier.state.maybeMap(loading: (s) => s.retryCount, orElse: () => -1),
        1,
      );

      verify(
        () => repository.getGameUrl(
          providerId: any(named: 'providerId'),
          productId: any(named: 'productId'),
          gameCode: any(named: 'gameCode'),
          lang: any(named: 'lang'),
          isMobileLogin: any(named: 'isMobileLogin'),
        ),
      ).called(1);
    });

    test(
      'reaching max retry count stops retrying with original failureType',
      () async {
        // Trigger a network failure first
        when(
          () => repository.getGameUrl(
            providerId: any(named: 'providerId'),
            productId: any(named: 'productId'),
            gameCode: any(named: 'gameCode'),
            lang: any(named: 'lang'),
            isMobileLogin: any(named: 'isMobileLogin'),
          ),
        ).thenThrow(const CaxiloNetworkFailure());

        await notifier.loadGameUrl();
        expect(notifier.state.failureType, GamePlayerErrorType.network);

        // retry() hits max 3
        notifier.retry(); // 1
        notifier.retry(); // 2
        notifier.retry(); // 3 (stops)

        expect(notifier.state, isA<GamePlayerFailureState>());
        notifier.state.mapOrNull(
          failure: (s) {
            expect(s.failureType, GamePlayerErrorType.network);
            expect(s.isRetryable, isFalse);
            expect(s.failureMessage, isNull);
          },
        );
      },
    );
  });

  group('GamePlayerNotifier - Memory Safety', () {
    test('should not update state after dispose', () async {
      when(() => orientationController.apply(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return OrientationApplyResult.matched(gamePolicy);
      });

      final future = notifier.initializePlayer(
        orientationController: orientationController,
        previousPolicy: previousPolicy,
        gamePolicy: gamePolicy,
      );

      notifier.dispose();

      await future;
    });
  });
}
