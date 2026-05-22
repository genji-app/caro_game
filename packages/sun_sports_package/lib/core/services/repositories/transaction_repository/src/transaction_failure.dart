/// {@template transaction_failure}
/// A base failure for the transaction repository failures.
/// {@endtemplate}
sealed class TransactionFailure implements Exception {
  /// {@macro transaction_failure}
  const TransactionFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'TransactionFailure(error: $error)';
}

/// Thrown when fetching transactions fails
class GetTransactionsFailure extends TransactionFailure {
  /// {@macro get_transactions_failure}
  const GetTransactionsFailure(super.error);
}
