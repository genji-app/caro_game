import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sun_sports/features/game/game.dart';

class MockGamePlayerNotifier extends StateNotifier<GamePlayerState>
    with Mock
    implements GamePlayerNotifier {
  MockGamePlayerNotifier() : super(const GamePlayerState.initial());
}

void main() {
  late MockGamePlayerNotifier mockNotifier;
  const game = GameBlock.inHouse(
    providerId: 'p1',
    providerName: 'P1',
    productId: 'prod1',
    gameCode: 'g1',
    gameName: 'Game 1',
    image: 'img.png',
    lang: 'vi',
    gameType: GameType.slot,
  );

  setUp(() {
    mockNotifier = MockGamePlayerNotifier();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [gamePlayerProvider(game).overrideWith((ref) => mockNotifier)],
      child: const MaterialApp(
        home: Scaffold(
          body: GamePlayerView(game: game, webViewId: 'test-id'),
        ),
      ),
    );
  }

  testWidgets('renders GamePlayerLoading when in loading state', (
    tester,
  ) async {
    mockNotifier.state = const GamePlayerState.loading(
      stage: GamePlayerLoadingStage.settingUp,
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(GamePlayerLoadingView), findsOneWidget);
    expect(find.byType(GamePlayerFailureView), findsNothing);
  });

  testWidgets('shows failure message when state is failure', (tester) async {
    mockNotifier.state = const GamePlayerState.failure(
      failureType: GamePlayerErrorType.network,
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(GamePlayerFailureView), findsOneWidget);
  });

  testWidgets(
    'orientationSetupFailed displays correct message and no retry button',
    (tester) async {
      mockNotifier.state = const GamePlayerState.failure(
        failureType: GamePlayerErrorType.orientationSetupFailed,
        isRetryable: false,
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Lỗi xoay màn hình'), findsOneWidget);
      expect(
        find.textContaining('Không thể áp dụng hướng màn hình'),
        findsOneWidget,
      );
      expect(
        find
            .descendant(
              of: find.byType(GamePlayerFailureView),
              matching: find.text('Quay lại'),
            )
            .first,
        findsOneWidget,
      );
      expect(find.text('Thử lại'), findsNothing);
    },
  );

  testWidgets('serverError displays API message as secondary', (tester) async {
    mockNotifier.state = const GamePlayerState.failure(
      failureType: GamePlayerErrorType.serverError,
      failureMessage: 'DB timeout',
      isRetryable: true,
    );

    await tester.pumpWidget(createTestWidget());

    expect(find.text('Lỗi máy chủ'), findsOneWidget);
    expect(find.text('DB timeout').first, findsOneWidget);
    expect(find.text('Thử lại').first, findsOneWidget);
  });

  testWidgets('serverError falls back to static message when no API message', (
    tester,
  ) async {
    mockNotifier.state = const GamePlayerState.failure(
      failureType: GamePlayerErrorType.serverError,
      failureMessage: null,
      isRetryable: false,
    );

    await tester.pumpWidget(createTestWidget());

    expect(
      find.text(
        'Máy chủ không phản hồi sau nhiều lần thử. Vui lòng thử lại sau.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('network exhausted displays back button', (tester) async {
    mockNotifier.state = const GamePlayerState.failure(
      failureType: GamePlayerErrorType.network,
      failureMessage: 'Không thể kết nối...',
      isRetryable: false,
    );

    await tester.pumpWidget(createTestWidget());

    expect(
      find
          .descendant(
            of: find.byType(GamePlayerFailureView),
            matching: find.text('Quay lại'),
          )
          .first,
      findsOneWidget,
    );
    expect(find.text('Thử lại'), findsNothing);
  });
}
