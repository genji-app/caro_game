import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

class DevMyBetRepository extends MyBetRepositoryRemote {
  DevMyBetRepository({SbHttpManager? http})
    : super(http: http ?? SbHttpManager.instance);

  @override
  String get token => '32-7f68463c3645da31a477fa68282e91a3';
}

final myBetRepositoryProvider = Provider<MyBetRepository>((ref) {
  // final repository = DevMyBetRepository(http: SbHttpManager.instance);
  final repository = MyBetRepositoryRemote(http: SbHttpManager.instance);
  // Warm up active count on provider initialization
  repository.refreshActiveCount();
  ref.onDispose(() => repository.dispose());
  return repository;
});
