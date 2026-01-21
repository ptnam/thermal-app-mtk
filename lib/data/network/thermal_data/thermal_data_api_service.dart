/// =============================================================================
/// File: thermal_data_api_service.dart
/// Description: API service for Thermal Data operations
///
/// Purpose:
/// - Handles all HTTP calls related to thermal monitoring data
/// - Provides thermal data queries for dashboards and reports
/// - Supports chart data and analysis endpoints
/// =============================================================================

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_result.dart';
import '../core/base_url_provider.dart';
import '../core/base_dto.dart';
import '../core/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'thermal_data_endpoints.dart';
import 'dto/thermal_data_dto.dart';

/// Service for ThermalData API calls
///
/// Provides methods for:
/// - Fetching thermal data for dashboards
/// - Paginated thermal data queries
/// - Chart data and analysis
/// - Machine component position queries
class ThermalDataApiService {
  ThermalDataApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  }) : _apiClient = apiClient,
       _baseUrlProvider = baseUrlProvider,
       _logger = logger ?? AppLogger(tag: 'ThermalDataApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Get machine component positions by area
  ///
  /// [areaId] - Area ID to query
  /// Returns: List of machine components with positions and temperature levels
  Future<ApiResult<List<ShortenMachineComponentDto>>>
  getMachineComponentPositionByArea({
    required int areaId,
    required String accessToken,
  }) async {
    _logger.info('Fetching machine component positions: areaId=$areaId');
    return _apiClient.send<List<ShortenMachineComponentDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.machineComponentPositionByArea,
        queryParameters: {'areaId': areaId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json
              .map((e) => ShortenMachineComponentDto.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  /// Get machines and thermal data by area
  ///
  /// [areaId] - Area ID to query
  /// Returns: Machine components with their latest thermal data
  Future<ApiResult<MachineComponentAndThermalDatas>>
  getMachineAndLatestDataByArea({
    required int areaId,
    required String accessToken,
  }) async {
    _logger.info('Fetching machines and thermal data: areaId=$areaId');
    return _apiClient.send<MachineComponentAndThermalDatas>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.machinesAndThermalDataByArea,
        queryParameters: {'areaId': areaId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineComponentAndThermalDatas.fromJson(json),
    );
  }

  /// Get latest thermal data by machine component
  ///
  /// [machineId] - Machine ID
  /// [id] - Component or sensor ID
  /// [deviceType] - Type of device (component or sensor)
  Future<ApiResult<Map<String, List<ThermalDataDetailExtend>>>>
  getLatestThermalByComponent({
    required int machineId,
    required int id,
    required DeviceType deviceType,
    required String accessToken,
  }) async {
    _logger.info('Fetching thermal by component: machineId=$machineId, id=$id');
    return _apiClient.send<Map<String, List<ThermalDataDetailExtend>>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.thermalByComponent,
        queryParameters: {
          'machineId': machineId,
          'id': id,
          'deviceType': deviceType.value,
        },
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is Map<String, dynamic>) {
          return json.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map(
                    (e) => ThermalDataDetailExtend.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
            ),
          );
        }
        return {};
      },
    );
  }

  /// Get paginated thermal data list
  ///
  /// [fromTime] - Start time for data range
  /// [toTime] - End time for data range
  /// [areaId] - Filter by area (optional)
  /// [machineId] - Filter by machine (optional)
  /// [machineComponentIds] - Filter by components (optional)
  /// [temperatureLevel] - Filter by temperature level (optional)
  /// [thresholdType] - Filter by threshold type (optional)
  /// [deltaMin] - Minimum delta value (optional)
  /// [deltaMax] - Maximum delta value (optional)
  Future<ApiResult<PagingResponse<ThermalDataDetailExtend>>> getList({
    required DateTime fromTime,
    required DateTime toTime,
    required String accessToken,
    int? areaId,
    int? machineId,
    List<int>? machineComponentIds,
    TemperatureLevel? temperatureLevel,
    ThresholdType? thresholdType,
    double? deltaMin,
    double? deltaMax,
    int page = 1,
    int pageSize = 10,
  }) async {
    _logger.info('Fetching thermal data list: page=$page');

    final queryParams = <String, dynamic>{
      'fromTime': fromTime.toIso8601String(),
      'toTime': toTime.toIso8601String(),
      'page': page,
      'pageSize': pageSize,
      if (areaId != null) 'areaId': areaId,
      if (machineId != null) 'machineId': machineId,
      if (machineComponentIds != null && machineComponentIds.isNotEmpty)
        'machineComponentIds[]': machineComponentIds,
      if (temperatureLevel != null) 'temperatureLevel': temperatureLevel.value,
      if (thresholdType != null) 'thresholdType': thresholdType.value,
      if (deltaMin != null) 'deltaMin': deltaMin,
      if (deltaMax != null) 'deltaMax': deltaMax,
    };

    return _apiClient.send<PagingResponse<ThermalDataDetailExtend>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) =>
          PagingResponse.fromJson(json, ThermalDataDetailExtend.fromJson),
    );
  }

  /// Get paginated thermal data grouped by component
  Future<ApiResult<PagingResponse<ThermalDataExtend>>> getListGrouped({
    required DateTime fromTime,
    required DateTime toTime,
    required String accessToken,
    int? areaId,
    int? machineId,
    List<int>? machineComponentIds,
    TemperatureLevel? temperatureLevel,
    ThresholdType? thresholdType,
    double? deltaMin,
    double? deltaMax,
    int page = 1,
    int pageSize = 10,
  }) async {
    _logger.info('Fetching grouped thermal data: page=$page');

    final queryParams = <String, dynamic>{
      'fromTime': fromTime.toIso8601String(),
      'toTime': toTime.toIso8601String(),
      'page': page,
      'pageSize': pageSize,
      if (areaId != null) 'areaId': areaId,
      if (machineId != null) 'machineId': machineId,
      if (machineComponentIds != null && machineComponentIds.isNotEmpty)
        'machineComponentIds[]': machineComponentIds,
      if (temperatureLevel != null) 'temperatureLevel': temperatureLevel.value,
      if (thresholdType != null) 'thresholdType': thresholdType.value,
      if (deltaMin != null) 'deltaMin': deltaMin,
      if (deltaMax != null) 'deltaMax': deltaMax,
    };

    return _apiClient.send<PagingResponse<ThermalDataExtend>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.listGroup,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) =>
          PagingResponse.fromJson(json, ThermalDataExtend.fromJson),
    );
  }

  /// Get thermal data details by time range for charts
  ///
  /// [machineId] - Machine ID
  /// [machineComponentId] - Component ID
  /// [monitorPointId] - Monitor point ID
  /// [monitorPointType] - Type of monitor point
  /// [startDate] - Start date for chart
  /// [endDate] - End date for chart
  Future<ApiResult<ChartOutput>> getDetailThermalData({
    required int machineId,
    required int machineComponentId,
    required int monitorPointId,
    required MonitorPointType monitorPointType,
    required DateTime startDate,
    required DateTime endDate,
    required String accessToken,
  }) async {
    _logger.info('Fetching detail thermal data for chart');
    return _apiClient.send<ChartOutput>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.detailThermalData,
        queryParameters: {
          'machineId': machineId,
          'machineComponentId': machineComponentId,
          'monitorPointId': monitorPointId,
          'monitorPointType': monitorPointType.value,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => ChartOutput.fromJson(json),
    );
  }

  /// Get environment thermal data by area
  ///
  /// [areaId] - Area ID to query
  /// Returns: Environment temperature and measurement frequency
  Future<ApiResult<EnvironmentThermalData>> getEnvironmentThermal({
    required int areaId,
    required String accessToken,
  }) async {
    _logger.info('Fetching environment thermal data: areaId=$areaId');
    return _apiClient.send<EnvironmentThermalData>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.environmentThermal,
        queryParameters: {'areaId': areaId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => EnvironmentThermalData.fromJson(json),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  ThermalDataEndpoints get _endpoints =>
      ThermalDataEndpoints(_baseUrlProvider.apiBaseUrl);

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
