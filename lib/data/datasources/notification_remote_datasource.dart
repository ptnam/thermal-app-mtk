import '../network/notification/notification_api_service.dart';
import '../network/notification/dto/notification_list_response_dto.dart';
import '../network/notification/dto/notification_detail_response_dto.dart';
import '../../core/logger/app_logger.dart';
import '../local/storage/token_cache_secure.dart';

/// Remote data source for notifications
class NotificationRemoteDataSource {
  final NotificationApiService apiService;
  final TokenCacheAdapter tokenCache;
  final AppLogger logger;

  NotificationRemoteDataSource({
    required this.apiService,
    required this.tokenCache,
    required this.logger,
  });

  Future<NotificationListResponseDto> getNotifications(Map<String, dynamic> queryParameters) async {
    try {
      final tokens = await tokenCache.read();
      final accessToken = tokens?.accessToken ?? '';
      if (accessToken.isEmpty) throw Exception('Access token missing');

      final result = await apiService.getNotifications(
        queryParameters: queryParameters,
        accessToken: accessToken,
      );

      return result.fold<NotificationListResponseDto>(
        onFailure: (err) => throw Exception('Failed to fetch notifications: ${err.message}'),
        onSuccess: (json) {
          if (json == null) throw Exception('Empty notifications response');
          final dto = NotificationListResponseDto.fromJson(json);
          return dto;
        },
      );
    } catch (e, st) {
      logger.error('Exception in getNotifications', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<NotificationDetailResponseDto> getNotificationDetail(String id, String dataTime) async {
    try {
      final tokens = await tokenCache.read();
      final accessToken = tokens?.accessToken ?? '';
      if (accessToken.isEmpty) throw Exception('Access token missing');

      final result = await apiService.getNotificationDetail(
        id: id,
        dataTime: dataTime,
        accessToken: accessToken,
      );

      return result.fold<NotificationDetailResponseDto>(
        onFailure: (err) => throw Exception('Failed to fetch notification detail: ${err.message}'),
        onSuccess: (json) {
          if (json == null) throw Exception('Empty notification detail response');
          return NotificationDetailResponseDto.fromJson(json);
        },
      );
    } catch (e, st) {
      logger.error('Exception in getNotificationDetail', error: e, stackTrace: st);
      rethrow;
    }
  }
}
