import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase extends UseCase<NotificationListEntity, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationListEntity>> call(GetNotificationsParams params) async {
    return await repository.getNotifications(queryParameters: params.queryParameters);
  }
}

class GetNotificationsParams {
  final Map<String, dynamic> queryParameters;

  GetNotificationsParams({required this.queryParameters});
}

class GetNotificationDetailUseCase extends UseCase<NotificationItemEntity, GetNotificationDetailParams> {
  final NotificationRepository repository;

  GetNotificationDetailUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationItemEntity>> call(GetNotificationDetailParams params) async {
    return await repository.getNotificationDetail(id: params.id, dataTime: params.dataTime);
  }
}

class GetNotificationDetailParams {
  final String id;
  final String dataTime;

  GetNotificationDetailParams({required this.id, required this.dataTime});
}
