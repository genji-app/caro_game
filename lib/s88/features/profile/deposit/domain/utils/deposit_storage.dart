import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';

/// Deposit Storage
///
/// Manages CodepayCreateQrResponse storage using Hive.
/// Key format: {userId}_{paymentMethod}_{bankName} (e.g., "user123_codepay_Vietcombank", "user123_ewallet_MoMo")
/// Value: JSON string of CodepayCreateQrResponse with remainingTime adjusted
/// Note: userId is required to prevent showing QR codes from other users
class DepositStorage {
  static const String _boxName = 'deposit_qr_responses';
  static Box<String>? _box;

  /// Initialize Hive box (call once at app startup)
  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Get Hive box instance
  static Box<String> get box {
    if (_box == null) {
      throw Exception('DepositStorage not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Save CodepayCreateQrResponse to Hive
  ///
  /// [response] - QR response to save
  /// [userId] - User ID (custId) to isolate storage per user
  /// [paymentMethod] - Payment method (codepay or eWallet)
  /// [walletName] - Optional wallet name for eWallet (if null, uses response.bankName)
  ///
  /// Key format: {userId}_{paymentMethod}_{bankName}
  /// - Codepay: "user123_codepay_Vietcombank"
  /// - EWallet: "user123_ewallet_MoMo" (uses walletName if provided, otherwise response.bankName)
  ///
  /// Value: JSON string with remainingTime adjusted (remainingTime + currentTime in milliseconds)
  /// Note: remainingTime is already in milliseconds
  static Future<void> saveCodepayResponse(
    CodepayCreateQrResponse response, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    if (userId.isEmpty) {
      debugPrint('Warning: saveCodepayResponse called with empty userId');
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final adjustedRemainingTime = response.remainingTime + currentTime;

    // Tạo key dựa trên userId, paymentMethod và walletName/bankName
    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      // EWallet: dùng walletName (tên wallet được chọn) thay vì response.bankName
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      // Codepay: dùng response.bankName
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_${response.bankName}';
    }

    final responseMap = {
      'bankAccount': response.bankAccount,
      'amount': response.amount,
      'statusId': response.statusId,
      'accountName': response.accountName,
      'bankBranch': response.bankBranch,
      'qrcode': response.qrcode,
      'codepay': response.codepay,
      'bankName': response.bankName,
      'message': response.message,
      'remainingTime': adjustedRemainingTime,
    };
    debugPrint(
      'save codepay: key=$storageKey, bankName=${response.bankName}, walletName=$walletName',
    );
    await box.put(storageKey, jsonEncode(responseMap));
  }

  /// Get CodepayCreateQrResponse from Hive
  ///
  /// [bankName] - Bank name or wallet name
  /// [userId] - User ID (custId) to get only this user's QR codes
  /// [paymentMethod] - Payment method (codepay or eWallet)
  /// [walletName] - Optional wallet name for eWallet (if null, uses bankName)
  ///
  /// Returns null if not found or expired
  /// Automatically removes expired entries
  /// Note: remainingTime is returned in milliseconds
  static CodepayCreateQrResponse? getCodepayResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) {
    if (userId.isEmpty) {
      debugPrint('Warning: getCodepayResponse called with empty userId');
      return null;
    }

    // Tạo key dựa trên userId, paymentMethod và walletName/bankName
    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      // EWallet: dùng walletName (tên wallet được chọn) thay vì bankName
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      // Codepay: dùng bankName
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_$bankName';
    }

    final jsonString = box.get(storageKey);
    if (jsonString == null) return null;

    try {
      final responseMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final savedRemainingTime = responseMap['remainingTime'] as int;

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final remainingTimeMs = savedRemainingTime - currentTime;

      if (remainingTimeMs <= 0) {
        _removeByStorageKey(storageKey);
        return null;
      }

      return CodepayCreateQrResponse(
        bankAccount: responseMap['bankAccount']?.toString() ?? '',
        amount: responseMap['amount'] as int? ?? 0,
        statusId: responseMap['statusId'] as int? ?? 0,
        accountName: responseMap['accountName']?.toString() ?? '',
        bankBranch: responseMap['bankBranch']?.toString() ?? '',
        qrcode: responseMap['qrcode']?.toString() ?? '',
        codepay: responseMap['codepay']?.toString() ?? '',
        bankName: responseMap['bankName']?.toString() ?? '',
        message: responseMap['message']?.toString() ?? '',
        remainingTime: remainingTimeMs,
      );
    } catch (e) {
      _removeByStorageKey(storageKey);
      return null;
    }
  }

  /// Remove by storage key directly (internal use)
  static Future<void> _removeByStorageKey(String storageKey) async {
    await box.delete(storageKey);
  }

  /// Remove CodepayCreateQrResponse from Hive
  ///
  /// [bankName] - Bank name or wallet name
  /// [userId] - User ID (custId) to remove only this user's QR code
  /// [paymentMethod] - Payment method (codepay or eWallet)
  /// [walletName] - Optional wallet name for eWallet (if null, uses bankName)
  static Future<void> removeCodepayResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    if (userId.isEmpty) {
      debugPrint('Warning: removeCodepayResponse called with empty userId');
      return;
    }

    // Tạo key giống như getCodepayResponse
    final String storageKey;
    if (paymentMethod == PaymentMethod.eWallet && walletName != null) {
      storageKey = '${userId}_ewallet_$walletName';
    } else {
      final prefix = paymentMethod == PaymentMethod.eWallet
          ? 'ewallet'
          : 'codepay';
      storageKey = '${userId}_${prefix}_$bankName';
    }
    await _removeByStorageKey(storageKey);
  }

  /// Check if response exists and is still valid
  ///
  /// [bankName] - Bank name or wallet name
  /// [userId] - User ID (custId) to check only this user's QR codes
  /// [paymentMethod] - Payment method (codepay or eWallet)
  /// [walletName] - Optional wallet name for eWallet (if null, uses bankName)
  static bool hasValidResponse(
    String bankName, {
    required String userId,
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) {
    return getCodepayResponse(
          bankName,
          userId: userId,
          paymentMethod: paymentMethod,
          walletName: walletName,
        ) !=
        null;
  }

  /// Clear all stored responses
  static Future<void> clearAll() async {
    await box.clear();
  }
}
