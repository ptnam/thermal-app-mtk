part of 'notification_bloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationListLoaded extends NotificationState {
  final NotificationListEntity list;

  NotificationListLoaded({required this.list});
}

class NotificationDetailLoaded extends NotificationState {
  final NotificationItemEntity item;

  NotificationDetailLoaded({required this.item});
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});
}
