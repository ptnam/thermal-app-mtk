/// =============================================================================
/// File: monitor_point_api_service.dart
/// Description: API service for Monitor Point operations
/// 
/// Purpose:
/// - Handles all HTTP calls for monitor point management
/// - Queries for camera and sensor monitor points
/// =============================================================================

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_result.dart';
import '../core/base_url_provider.dart';
import '../core/endpoints.dart';
import '../../../core/logger/app_logger.dart';
import 'dto/monitor_point_dto.dart';

/// Monitor Point endpoints
class MonitorPointEndpoints extends Endpoints {
  MonitorPointEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all monitor points by camera
  String allByCamera(int cameraId) => path('/api/MonitorPoints/allbycam/$cameraId');

  /// GET: Get all by camera and status
  String allByCameraAndStatus(int cameraId) =>
      path('/api/MonitorPoints/allByCamAndStatus/$cameraId');

  /// GET: Get all monitor points by sensor
  String allBySensor(int sensorId) => path('/api/MonitorPoints/allbysensor/$sensorId');

  /// GET: Get all by sensor and status
  String allBySensorAndStatus(int sensorId) =>
      path('/api/MonitorPoints/allBySensorAndStatus/$sensorId');

  /// GET: Get all by machine component
  /// Query params: machineComponentId
  String get allByMachineComponent => path('/api/MonitorPoints/allByMachineComponent');
}

/// Service for Monitor Point API calls
class MonitorPointApiService {
  MonitorPointApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'MonitorPointApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Get all monitor points by camera
  Future<ApiResult<List<CameraMonitorPointExtendDto>>> getAllByCamera({
    required int cameraId,
    required String accessToken,
  }) async {
    _logger.info('Fetching monitor points by camera: cameraId=$cameraId');
    return _apiClient.send<List<CameraMonitorPointExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allByCamera(cameraId),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => CameraMonitorPointExtendDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get all monitor points by camera and status
  Future<ApiResult<List<CameraMonitorPointExtendDto>>> getAllByCameraAndStatus({
    required int cameraId,
    required String accessToken,
  }) async {
    _logger.info('Fetching monitor points by camera with status: cameraId=$cameraId');
    return _apiClient.send<List<CameraMonitorPointExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allByCameraAndStatus(cameraId),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => CameraMonitorPointExtendDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get all monitor points by sensor
  Future<ApiResult<List<SensorMonitorPointExtendDto>>> getAllBySensor({
    required int sensorId,
    required String accessToken,
  }) async {
    _logger.info('Fetching monitor points by sensor: sensorId=$sensorId');
    return _apiClient.send<List<SensorMonitorPointExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allBySensor(sensorId),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => SensorMonitorPointExtendDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get all monitor points by sensor and status
  Future<ApiResult<List<SensorMonitorPointExtendDto>>> getAllBySensorAndStatus({
    required int sensorId,
    required String accessToken,
  }) async {
    _logger.info('Fetching monitor points by sensor with status: sensorId=$sensorId');
    return _apiClient.send<List<SensorMonitorPointExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allBySensorAndStatus(sensorId),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => SensorMonitorPointExtendDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get all monitor points by machine component
  Future<ApiResult<List<GeneralMonitorPointDto>>> getAllByMachineComponent({
    required int machineComponentId,
    required String accessToken,
  }) async {
    _logger.info('Fetching monitor points by component: componentId=$machineComponentId');
    return _apiClient.send<List<GeneralMonitorPointDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allByMachineComponent,
        queryParameters: {'machineComponentId': machineComponentId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => GeneralMonitorPointDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  MonitorPointEndpoints get _endpoints =>
      MonitorPointEndpoints(_baseUrlProvider.apiBaseUrl);

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
