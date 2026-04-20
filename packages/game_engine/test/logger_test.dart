import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';

void main() {
  test('silentLogger does nothing', () {
    expect(() => silentLogger('info', 'test'), returnsNormally);
    expect(
      () => silentLogger(
        'error',
        'test',
        error: Exception(),
        stackTrace: StackTrace.current,
      ),
      returnsNormally,
    );
  });
}
