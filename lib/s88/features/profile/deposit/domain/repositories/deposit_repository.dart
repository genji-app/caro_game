import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';

/// Abstract repository interface for deposit
/// Domain layer only knows about this contract, not the implementation
abstract class DepositRepository {
  Future<Either<Failure, FetchBankAccountsData>> getConfigDeposit();

  /// Submit bank deposit
  Future<Either<Failure, DepositResponse>> submitBankDeposit(
    BankDepositRequest request,
  );

  /// Submit codepay deposit
  Future<Either<Failure, DepositResponse>> submitCodepayDeposit(
    CodepayDepositRequest request,
  );

  /// Submit crypto deposit
  Future<Either<Failure, DepositResponse>> submitCryptoDeposit(
    CryptoDepositRequest request,
  );

  /// Submit scratch card deposit
  Future<Either<Failure, DepositResponse>> submitCardDeposit(
    CardDepositRequest request,
  );

  /// Submit giftcode deposit
  Future<Either<Failure, DepositResponse>> submitGiftcodeDeposit(
    GiftcodeDepositRequest request,
  );

  /// Create bank transaction slip
  /// API: {apiDomain}paygate?command=createTransactionSlip
  Future<Either<Failure, DepositResponse>> createTransactionSlip(
    BankTransactionSlipRequest request,
  );

  /// Create Codepay QR code
  /// API: {apiDomain}paygate?command=createCodePay
  Future<Either<Failure, CodepayCreateQrResponse>> createCodePay(
    CodepayCreateQrRequest request,
  );

  /// Check Codepay QR code (check if previously created)
  /// API: {apiDomain}paygate?command=checkCodePay
  /// Called when item in Codepay or eWallet is selected
  Future<Either<Failure, CodepayCreateQrResponse>> checkCodePay(
    CheckCodePayRequest request,
  );

  /// Get crypto address
  /// API: {apiDomain}paygate?command=getCryptoAddress
  Future<Either<Failure, CryptoAddressResponse>> getCryptoAddress(
    CryptoAddressRequest request,
  );

  /// Verify bank account
  /// API: https://api1.azhkthg1.net/paygate?command=userCreateBankAccount
  Future<Either<Failure, String>> verifyBankAccount({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  });
}
