import '../network/camera/camera_stream_api_service.dart';
import '../network/camera/dto/camera_stream_dto.dart';
import '../../core/logger/app_logger.dart';
import 'camera_local_datasource.dart';

/// Remote data source for Camera Stream
/// Responsible for API calls to fetch camera stream data
class CameraRemoteDataSource {
  final CameraStreamApiService apiService;
  final CameraLocalDataSource localDataSource;
  final AppLogger logger;

  CameraRemoteDataSource({
    required this.apiService,
    required this.localDataSource,
    dynamic errorMapper,
    required this.logger,
  });

  /// Fetch camera stream from API
  /// [cameraId] - ID của camera
  Future<CameraStreamDto> getCameraStream(int cameraId) async {
    try {
      // Get access token
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not available');
      }
      
      final result = await apiService.getCameraStream(
        cameraId: cameraId,
        accessToken: accessToken,
      );

      return result.fold<CameraStreamDto>(
        onFailure: (error) {
          throw Exception('Failed to get camera stream: ${error.message}');
        },
        onSuccess: (dto) {
          if (dto == null) {
            throw Exception('Camera stream for ID $cameraId not found');
          }
          return dto;
        },
      );
    } catch (e, st) {
      logger.error('Exception fetching camera stream $cameraId', error: e, stackTrace: st);
      rethrow;
    }
  }
}
