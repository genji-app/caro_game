import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(httpManager: SbHttpManager.instance),
);
