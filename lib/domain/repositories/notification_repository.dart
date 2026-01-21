import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationListEntity>> getNotifications({required Map<String, dynamic> queryParameters});

  Future<Either<Failure, NotificationItemEntity>> getNotificationDetail({required String id, required String dataTime});
}
