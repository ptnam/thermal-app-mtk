/// =============================================================================
/// File: sensor_api_service.dart
/// Description: API service for Sensor management operations
/// 
/// Purpose:
/// - Handles all HTTP calls related to Sensor management
/// - CRUD operations for sensors and sensor types
/// =============================================================================

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_result.dart';
import '../core/base_url_provider.dart';
import '../core/base_dto.dart';
import '../core/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'sensor_endpoints.dart';
import 'dto/sensor_dto.dart';
import 'dto/sensor_type_dto.dart';

/// Service for Sensor API calls
/// 
/// Provides methods for:
/// - Fetching sensor lists (all, paginated)
/// - CRUD operations on sensors
/// - Sensor type management
class SensorApiService {
  SensorApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'SensorApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Sensor CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all sensors (shortened list)
  /// 
  /// [areaId] - Filter by area (optional)
  /// [sensorTypeId] - Filter by sensor type (optional)
  Future<ApiResult<List<ShortenBaseDto>>> getAll({
    required String accessToken,
    int? areaId,
    int? sensorTypeId,
  }) async {
    _logger.info('Fetching all sensors');
    
    final queryParams = <String, dynamic>{
      if (areaId != null) 'areaId': areaId,
      if (sensorTypeId != null) 'sensorTypeId': sensorTypeId,
    };

    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorEndpoints.all,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => ShortenBaseDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated sensor list
  Future<ApiResult<PagingResponse<SensorDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    int? areaId,
    int? sensorTypeId,
    MonitorType? monitorType,
    String? name,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching sensor list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (areaId != null) 'areaId': areaId,
      if (sensorTypeId != null) 'sensorTypeId': sensorTypeId,
      if (monitorType != null) 'monitorType': monitorType.value,
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<SensorDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, SensorDto.fromJson),
    );
  }

  /// Get sensor by ID
  Future<ApiResult<SensorDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching sensor: id=$id');
    return _apiClient.send<SensorDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorDto.fromJson(json),
    );
  }

  /// Create new sensor
  Future<ApiResult<SensorDto>> create({
    required SensorDto sensor,
    required String accessToken,
  }) async {
    _logger.info('Creating sensor: ${sensor.name}');
    return _apiClient.send<SensorDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _sensorEndpoints.create,
        data: sensor.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorDto.fromJson(json),
    );
  }

  /// Update sensor by ID
  Future<ApiResult<SensorDto>> update({
    required int id,
    required SensorDto sensor,
    required String accessToken,
  }) async {
    _logger.info('Updating sensor: id=$id');
    return _apiClient.send<SensorDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _sensorEndpoints.update(id),
        data: sensor.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorDto.fromJson(json),
    );
  }

  /// Delete sensor by ID
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting sensor: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _sensorEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sensor Type Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all sensor types (shortened list)
  Future<ApiResult<List<ShortenBaseDto>>> getAllTypes({
    required String accessToken,
  }) async {
    _logger.info('Fetching all sensor types');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorTypeEndpoints.all,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => ShortenBaseDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated sensor type list
  Future<ApiResult<PagingResponse<SensorTypeDto>>> getTypeList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching sensor type list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<SensorTypeDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorTypeEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, SensorTypeDto.fromJson),
    );
  }

  /// Get sensor type by ID
  Future<ApiResult<SensorTypeDto>> getTypeById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching sensor type: id=$id');
    return _apiClient.send<SensorTypeDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _sensorTypeEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorTypeDto.fromJson(json),
    );
  }

  /// Create new sensor type
  Future<ApiResult<SensorTypeDto>> createType({
    required SensorTypeDto sensorType,
    required String accessToken,
  }) async {
    _logger.info('Creating sensor type: ${sensorType.name}');
    return _apiClient.send<SensorTypeDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _sensorTypeEndpoints.create,
        data: sensorType.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorTypeDto.fromJson(json),
    );
  }

  /// Update sensor type by ID
  Future<ApiResult<SensorTypeDto>> updateType({
    required int id,
    required SensorTypeDto sensorType,
    required String accessToken,
  }) async {
    _logger.info('Updating sensor type: id=$id');
    return _apiClient.send<SensorTypeDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _sensorTypeEndpoints.update(id),
        data: sensorType.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => SensorTypeDto.fromJson(json),
    );
  }

  /// Delete sensor type by ID
  Future<ApiResult<void>> deleteType({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting sensor type: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _sensorTypeEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  SensorEndpoints get _sensorEndpoints =>
      SensorEndpoints(_baseUrlProvider.apiBaseUrl);
  SensorTypeEndpoints get _sensorTypeEndpoints =>
      SensorTypeEndpoints(_baseUrlProvider.apiBaseUrl);

  Options _authorizedOptions(String accessToken) {
    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
