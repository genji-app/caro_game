import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api_client/game_api_client.dart' as gac;

void main() {
  group('CaxiloFailure — domain properties', () {
    test('isRetryable defaults to false', () {
      expect(const CaxiloAuthFailure().isRetryable, isFalse);
      expect(const CaxiloMaintenanceFailure().isRetryable, isFalse);
      expect(const CaxiloComingSoonFailure().isRetryable, isFalse);
      expect(const CaxiloDisabledFailure().isRetryable, isFalse);
      expect(const CaxiloUnderDevelopmentFailure().isRetryable, isFalse);
      expect(const CaxiloUnknownFailure().isRetryable, isFalse);
    });

    test('CaxiloNetworkFailure is retryable', () {
      expect(const CaxiloNetworkFailure().isRetryable, isTrue);
    });

    test('CaxiloServerFailure is retryable', () {
      expect(const CaxiloServerFailure().isRetryable, isTrue);
    });

    test('CaxiloBusinessFailure carries operator message', () {
      const failure = CaxiloBusinessFailure(message: 'Số dư không đủ');
      expect(failure.message, equals('Số dư không đủ'));
      expect(failure.isRetryable, isFalse);
    });

    test('CaxiloGameUnavailableFailure subtypes are assignable to base', () {
      const coming = CaxiloComingSoonFailure();
      const disabled = CaxiloDisabledFailure();
      const underDev = CaxiloUnderDevelopmentFailure();

      expect(coming, isA<CaxiloGameUnavailableFailure>());
      expect(disabled, isA<CaxiloGameUnavailableFailure>());
      expect(underDev, isA<CaxiloGameUnavailableFailure>());
    });

    test('source is preserved for logging', () {
      final original = Exception('root cause');
      final failure = CaxiloNetworkFailure(source: original);
      expect(failure.source, same(original));
    });
  });

  group('CaxiloFailure - message field', () {
    test('CaxiloServerFailure carries message', () {
      const failure = CaxiloServerFailure(message: 'DB timeout');
      expect(failure.message, equals('DB timeout'));
      expect(failure.isRetryable, isTrue);
    });

    test('CaxiloServerFailure message defaults to null', () {
      const failure = CaxiloServerFailure();
      expect(failure.message, isNull);
    });

    test('CaxiloUnknownFailure carries message', () {
      const failure = CaxiloUnknownFailure(message: 'Parse error');
      expect(failure.message, equals('Parse error'));
    });

    test('CaxiloBusinessFailure message accessible via base class field', () {
      const failure = CaxiloBusinessFailure(message: 'Tài khoản bị khóa');
      expect(failure.message, equals('Tài khoản bị khóa'));
    });

    test('CaxiloNetworkFailure message is null (no API message)', () {
      const failure = CaxiloNetworkFailure();
      expect(failure.message, isNull);
    });
  });

  group('mapToCaxiloFailure — idempotent pass-through', () {
    test('returns same instance when input is already CaxiloFailure', () {
      const input = CaxiloNetworkFailure();
      final result = mapToCaxiloFailure(input);
      expect(result, same(input));
    });
  });

  group('mapToCaxiloFailure — InHouseGame exceptions', () {
    test('InHouseGameMaintenanceException → CaxiloMaintenanceFailure', () {
      final result = mapToCaxiloFailure(const InHouseGameMaintenanceException());
      expect(result, isA<CaxiloMaintenanceFailure>());
    });

    test('InHouseGameComingSoonException → CaxiloComingSoonFailure', () {
      final result = mapToCaxiloFailure(const InHouseGameComingSoonException());
      expect(result, isA<CaxiloComingSoonFailure>());
    });

    test('InHouseGameDisabledException → CaxiloDisabledFailure', () {
      final result = mapToCaxiloFailure(const InHouseGameDisabledException());
      expect(result, isA<CaxiloDisabledFailure>());
    });

    test('InHouseGameUnderDevelopmentException → CaxiloUnderDevelopmentFailure', () {
      final result = mapToCaxiloFailure(const InHouseGameUnderDevelopmentException());
      expect(result, isA<CaxiloUnderDevelopmentFailure>());
    });

    test('Other InHouseGameException → CaxiloUnknownFailure', () {
      final result = mapToCaxiloFailure(const InHouseGameUrlFetchException('fetch error'));
      expect(result, isA<CaxiloUnknownFailure>());
    });

    test('source is set to original exception', () {
      const original = InHouseGameMaintenanceException();
      final result = mapToCaxiloFailure(original) as CaxiloMaintenanceFailure;
      expect(result.source, same(original));
    });
  });

  group('mapToCaxiloFailure — message preservation', () {
    gac.GameApiException makeException(gac.GameApiExceptionType type, {String message = 'error'}) =>
        gac.GameApiException(message: message, type: type);

    test('serverError preserves GameApiException.message', () {
      final input = makeException(gac.GameApiExceptionType.serverError, message: 'DB timeout');
      final result = mapToCaxiloFailure(input);
      expect(result, isA<CaxiloServerFailure>());
      expect(result.message, equals('DB timeout'));
    });

    test('unknownError preserves GameApiException.message', () {
      final input = makeException(
        gac.GameApiExceptionType.parsingError,
        message: 'JSON decode error',
      );
      final result = mapToCaxiloFailure(input);
      expect(result, isA<CaxiloUnknownFailure>());
      expect(result.message, equals('JSON decode error'));
    });

    test('networkError message is null', () {
      final input = makeException(
        gac.GameApiExceptionType.networkError,
        message: 'Connection refused',
      );
      final result = mapToCaxiloFailure(input);
      expect(result, isA<CaxiloNetworkFailure>());
      expect(result.message, isNull);
    });
  });

  group('mapToCaxiloFailure — GameApiException types', () {
    gac.GameApiException makeException(gac.GameApiExceptionType type, {String message = 'error'}) =>
        gac.GameApiException(message: message, type: type);

    test('networkError → CaxiloNetworkFailure (retryable)', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.networkError));
      expect(result, isA<CaxiloNetworkFailure>());
      expect(result.isRetryable, isTrue);
    });

    test('timeout → CaxiloNetworkFailure (retryable)', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.timeout));
      expect(result, isA<CaxiloNetworkFailure>());
      expect(result.isRetryable, isTrue);
    });

    test('authenticationError → CaxiloAuthFailure (not retryable)', () {
      final result = mapToCaxiloFailure(
        makeException(gac.GameApiExceptionType.authenticationError),
      );
      expect(result, isA<CaxiloAuthFailure>());
      expect(result.isRetryable, isFalse);
    });

    test('tokenRefreshError → CaxiloAuthFailure (not retryable)', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.tokenRefreshError));
      expect(result, isA<CaxiloAuthFailure>());
      expect(result.isRetryable, isFalse);
    });

    test('serverError → CaxiloServerFailure (retryable)', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.serverError));
      expect(result, isA<CaxiloServerFailure>());
      expect(result.isRetryable, isTrue);
    });

    test('businessError → CaxiloBusinessFailure with message', () {
      final result = mapToCaxiloFailure(
        makeException(gac.GameApiExceptionType.businessError, message: 'Tài khoản bị khóa'),
      );
      expect(result, isA<CaxiloBusinessFailure>());
      expect(result.message, equals('Tài khoản bị khóa'));
      expect(result.isRetryable, isFalse);
    });

    test('clientError → CaxiloBusinessFailure with message', () {
      final result = mapToCaxiloFailure(
        makeException(gac.GameApiExceptionType.clientError, message: 'Yêu cầu không hợp lệ'),
      );
      expect(result, isA<CaxiloBusinessFailure>());
      expect(result.message, equals('Yêu cầu không hợp lệ'));
    });

    test('unknown → CaxiloUnknownFailure', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.unknown));
      expect(result, isA<CaxiloUnknownFailure>());
    });

    test('parsingError → CaxiloUnknownFailure', () {
      final result = mapToCaxiloFailure(makeException(gac.GameApiExceptionType.parsingError));
      expect(result, isA<CaxiloUnknownFailure>());
    });

    test('source is set to original GameApiException', () {
      final original = makeException(gac.GameApiExceptionType.serverError);
      final result = mapToCaxiloFailure(original) as CaxiloServerFailure;
      expect(result.source, same(original));
    });
  });

  group('mapToCaxiloFailure — fallback for unknown exceptions', () {
    test('arbitrary exception → CaxiloUnknownFailure', () {
      final result = mapToCaxiloFailure(Exception('something unexpected'));
      expect(result, isA<CaxiloUnknownFailure>());
    });

    test('arbitrary error → CaxiloUnknownFailure', () {
      final result = mapToCaxiloFailure(StateError('bad state'));
      expect(result, isA<CaxiloUnknownFailure>());
    });

    test('source is set to original exception', () {
      final original = Exception('unknown');
      final result = mapToCaxiloFailure(original) as CaxiloUnknownFailure;
      expect(result.source, same(original));
    });
  });
}
