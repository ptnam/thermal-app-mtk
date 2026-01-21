import '../network/area/area_api_service.dart';
import '../network/area/dto/area_tree_dto.dart';
import '../../../core/logger/app_logger.dart';

/// Remote data source for Area
/// Responsible for API calls to fetch area data
class AreaRemoteDataSource {
  final AreaApiService _areaApiService;
  final AppLogger _logger;

  AreaRemoteDataSource(
    this._areaApiService, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(tag: 'AreaRemoteDataSource');

  /// Fetch complete area tree with cameras from API
  Future<List<AreaTreeDto>> getAreaTreeWithCameras(String accessToken) async {
    try {
      final result = await _areaApiService.getAreaTreeWithCameras(
        accessToken: accessToken,
      );
      
      return result.fold<List<AreaTreeDto>>(
        onFailure: (error) {
          throw Exception('Failed to get area tree: ${error.message}');
        },
        onSuccess: (dtos) {
          return dtos ?? [];
        },
      );
    } catch (e, st) {
      _logger.error('Exception fetching area tree', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Fetch single area by ID from API
  Future<AreaTreeDto> getAreaById(int id, String accessToken) async {
    try {
      final result = await _areaApiService.getAreaById(
        id: id,
        accessToken: accessToken,
      );
      
      return result.fold<AreaTreeDto>(
        onFailure: (error) {
          throw Exception('Failed to get area $id: ${error.message}');
        },
        onSuccess: (dto) {
          if (dto == null) {
            throw Exception('Area $id not found');
          }
          return dto;
        },
      );
    } catch (e, st) {
      _logger.error('Exception fetching area $id', error: e, stackTrace: st);
      rethrow;
    }
  }
}
