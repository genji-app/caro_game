import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

/// Implementation of WithdrawRepository using SbHttpManager
class WithdrawRepositoryImpl implements WithdrawRepository {
  final SbHttpManager _httpManager;
  final AppLogger _logger = AppLogger(tag: 'WithdrawRepository');

  WithdrawRepositoryImpl({SbHttpManager? httpManager})
    : _httpManager = httpManager ?? SbHttpManager.instance;

  @override
  Future<Either<Failure, WithdrawResponse>> submitBankWithdraw(
    WithdrawBankRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      // Build URL with query parameters
      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'createTransactionSlip',
              'bankId': request.bankId,
              'slipType': request.slipType.toString(),
              'amount': request.amount.toString(),
              'accountName': request.accountName,
              'accountNumber': request.accountNumber,
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      // Validate response
      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      // Parse response
      final response = WithdrawResponse.fromJson(responseJson);

      // Status = 0 => success
      if (response.status != 0) {
        final message =
            response.data.message ??
            responseJson['messageKey']?.toString() ??
            responseJson['message']?.toString() ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message));
      }

      _logger.d('✅ Withdraw success: ${response.data.message}');

      return Right(response);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to submit bank withdraw',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WithdrawResponse>> submitCardWithdraw(
    WithdrawCardRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      // Build URL with query parameters
      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {'command': 'cashout', 'itemId': request.itemId},
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      // Validate response
      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      // Parse response
      final response = WithdrawResponse.fromJson(responseJson);

      // Status = 0 => success
      if (response.status != 0) {
        final message =
            response.data.message ??
            responseJson['messageKey']?.toString() ??
            responseJson['message']?.toString() ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message));
      }

      _logger.d('✅ Card withdraw success: ${response.data.message}');

      return Right(response);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to submit card withdraw',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WithdrawResponse>> submitCryptoWithdraw(
    WithdrawCryptoRequest request,
  ) async {
    try {
      final config = SbConfig.instance;
      final apiDomain = config.mainConfig['api_domain'] as String? ?? '';

      if (apiDomain.isEmpty) {
        return Left(ServerFailure(message: 'API domain not configured'));
      }

      final normalizedApiDomain = apiDomain.endsWith('/')
          ? apiDomain
          : '$apiDomain/';

      // Build URL with query parameters
      final url = Uri.parse('${normalizedApiDomain}paygate')
          .replace(
            queryParameters: {
              'command': 'createCryptoTransactionSlip',
              'network': request.network.toUpperCase(),
              'cryptoCurrency': request.cryptoCurrency.toUpperCase(),
              'fiatCurrency': request.fiatCurrency.toUpperCase(),
              'amount': request.amount.toString(),
              'address': request.address,
            },
          )
          .toString();

      final userToken = SbHttpManager.instance.userToken;
      if (userToken.isEmpty) {
        return Left(ServerFailure(message: 'User token not available'));
      }

      final responseJson = await _httpManager.send(
        url,
        json: true,
        authorization: true,
        token: userToken,
      );

      // Validate response
      if (responseJson == null) {
        return Left(ServerFailure(message: 'Empty response from server'));
      }

      if (responseJson is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Invalid response format'));
      }

      // Parse response
      final response = WithdrawResponse.fromJson(responseJson);

      // Status = 0 => success
      if (response.status != 0) {
        final message =
            response.data.message ??
            responseJson['messageKey']?.toString() ??
            responseJson['message']?.toString() ??
            'Có lỗi xảy ra';
        return Left(ServerFailure(message: message));
      }

      _logger.d('✅ Crypto withdraw success: ${response.data.message}');

      return Right(response);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to submit crypto withdraw',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
