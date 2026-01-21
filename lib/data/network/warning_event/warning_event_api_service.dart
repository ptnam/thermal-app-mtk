/// =============================================================================
/// File: warning_event_api_service.dart
/// Description: API service for Warning Event operations
/// 
/// Purpose:
/// - Handles all HTTP calls for warning event management
/// - CRUD operations for warning events
/// =============================================================================

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_result.dart';
import '../core/base_url_provider.dart';
import '../core/base_dto.dart';
import '../core/paging_response.dart';
import '../core/endpoints.dart';
import '../../../core/logger/app_logger.dart';
import 'dto/warning_event_dto.dart';

/// Warning Event endpoints
class WarningEventEndpoints extends Endpoints {
  WarningEventEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all warning events
  /// Query params: warningType
  String get all => path('/api/WarningEvents/all');

  /// GET: Get paginated list
  String get list => path('/api/WarningEvents/list');

  /// GET: Get by ID
  String byId(int id) => path('/api/WarningEvents/$id');

  /// POST: Create
  String get create => path('/api/WarningEvents');

  /// PUT: Update
  String update(int id) => path('/api/WarningEvents/$id');

  /// DELETE: Delete
  String delete(int id) => path('/api/WarningEvents/$id');
}

/// Service for Warning Event API calls
class WarningEventApiService {
  WarningEventApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'WarningEventApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Get all warning events
  Future<ApiResult<List<ShortenBaseDto>>> getAll({
    required String accessToken,
    WarningType? warningType,
  }) async {
    _logger.info('Fetching all warning events');
    
    final queryParams = <String, dynamic>{
      if (warningType != null) 'warningType': warningType.value,
    };

    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.all,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
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

  /// Get paginated warning event list
  Future<ApiResult<PagingResponse<WarningEventDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching warning event list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<WarningEventDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, WarningEventDto.fromJson),
    );
  }

  /// Get warning event by ID
  Future<ApiResult<WarningEventDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching warning event: id=$id');
    return _apiClient.send<WarningEventDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => WarningEventDto.fromJson(json),
    );
  }

  /// Create warning event
  Future<ApiResult<WarningEventDto>> create({
    required WarningEventDto warningEvent,
    required String accessToken,
  }) async {
    _logger.info('Creating warning event: ${warningEvent.name}');
    return _apiClient.send<WarningEventDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.create,
        data: warningEvent.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => WarningEventDto.fromJson(json),
    );
  }

  /// Update warning event
  Future<ApiResult<WarningEventDto>> update({
    required int id,
    required WarningEventDto warningEvent,
    required String accessToken,
  }) async {
    _logger.info('Updating warning event: id=$id');
    return _apiClient.send<WarningEventDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.update(id),
        data: warningEvent.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => WarningEventDto.fromJson(json),
    );
  }

  /// Delete warning event
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting warning event: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _endpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  WarningEventEndpoints get _endpoints =>
      WarningEventEndpoints(_baseUrlProvider.apiBaseUrl);

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
