import 'package:bloc/bloc.dart';
import 'package:camera_viewer/core/logger/app_logger.dart';
import 'package:camera_viewer/domain/entities/notification.dart';
import 'package:camera_viewer/domain/usecase/notification_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetNotificationDetailUseCase getNotificationDetailUseCase;
  final AppLogger logger;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.getNotificationDetailUseCase,
    required this.logger,
  }) : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<LoadNotificationDetailEvent>(_onLoadNotificationDetail);
  }

  Future<void> _onLoadNotifications(LoadNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final result = await getNotificationsUseCase(GetNotificationsParams(queryParameters: event.queryParameters));
      result.fold((failure) {
        logger.error('BLoC: Failure received: ${failure.message}');
        emit(NotificationError(message: failure.message));
      }, (list) {
        emit(NotificationListLoaded(list: list));
      });
    } catch (e, st) {
      logger.error('Exception in LoadNotifications', error: e, stackTrace: st);
      emit(NotificationError(message: 'Lỗi khi tải danh sách thông báo'));
    }
  }

  Future<void> _onLoadNotificationDetail(LoadNotificationDetailEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final result = await getNotificationDetailUseCase(GetNotificationDetailParams(id: event.id, dataTime: event.dataTime));
      result.fold((failure) {
        logger.error('BLoC: Failure received: ${failure.message}');
        emit(NotificationError(message: failure.message));
      }, (item) {
        emit(NotificationDetailLoaded(item: item));
      });
    } catch (e, st) {
      logger.error('Exception in LoadNotificationDetail', error: e, stackTrace: st);
      emit(NotificationError(message: 'Lỗi khi tải chi tiết thông báo'));
    }
  }
}
