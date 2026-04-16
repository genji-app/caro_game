import 'package:co_caro_flame/s88/core/services/repositories/user_repository/src/user_repository.dart';
import 'package:co_caro_flame/s88/features/notification/domain/notification_item.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final UserRepository _repository;

  Future<List<NotificationItem>> call() => _repository.fetchNotifications();
}
