import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

class PaginatedTransactions {
  final List<Transaction> items; // Danh sách dữ liệu trang hiện tại
  final int totalCount; // Tổng số bản ghi (biến count của bạn)
  final int currentCursor; // Chính là biến current/skip bạn truyền vào ban đầu
  final int limit; // Số lượng item mỗi trang
  final int? nextCursor; // Offset cho trang tiếp theo (null nếu hết dữ liệu)
  final bool isLastPage; // Cờ báo hiệu đã đến trang cuối

  PaginatedTransactions({
    required this.items,
    required this.totalCount,
    required this.currentCursor,
    required this.limit,
    required this.isLastPage,
    this.nextCursor,
  });
}

/// Repository for fetching user transactions from the API.
class TransactionRepository {
  TransactionRepository({required SbHttpManager httpManager})
    : _httpManager = httpManager;

  final SbHttpManager _httpManager;

  /// Requests transactions.
  ///
  /// Supported parameters:
  /// * [limit] - The number of results to return.
  /// * [cursor] - The (zero-based) offset of the first item
  /// in the collection to return.
  Future<PaginatedTransactions> getTransactions({
    int limit = 15,
    int? cursor,
  }) async {
    try {
      final skip = cursor ?? 0;

      final response = await _httpManager.getTransactionSlipHistory(
        skip: skip,
        limit: limit,
        slipType: 0,
      );

      return _paginate(response, skip, limit);
    } catch (e, stackTrace) {
      debugPrint('Failed to get transactions: $e\n$stackTrace');
      Error.throwWithStackTrace(GetTransactionsFailure(e), stackTrace);
    }
  }

  PaginatedTransactions _paginate(
    TransactionResponseData data,
    int skip,
    int limit,
  ) {
    final current = skip;
    final count = data.count;
    final items = data.items;

    final bool isLastPage = (current + items.length) >= count;
    final int? nextCursor = isLastPage ? null : (current + limit);

    return PaginatedTransactions(
      items: items,
      totalCount: count,
      currentCursor: current,
      limit: limit,
      nextCursor: nextCursor,
      isLastPage: isLastPage,
    );
  }
}

/// Extension to helpers for [TransactionFailure]
extension TransactionFailureX on TransactionFailure {
  /// Get user friendly error message
  String? get errorMessage {
    final err = error;

    if (err is SunApiException) {
      return err.userFriendlyMessage;
    }

    // Handle generic Exception
    if (err is Exception) {
      return err.toString().replaceFirst('Exception: ', '');
    }

    // Default message
    return null;
  }
}
