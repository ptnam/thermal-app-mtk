/// =============================================================================
/// File: sensor_repository_impl.dart
/// Description: Implementation of ISensorRepository interface
///
/// Purpose:
/// - Implements domain repository interface for sensors
/// - Converts API responses to domain entities
/// - Handles errors and maps to ApiError
/// =============================================================================

import 'package:dartz/dartz.dart';

import '../../domain/entities/sensor_entity.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../network/core/api_error.dart';
import '../network/core/paging_response.dart';
import '../network/core/base_dto.dart';
import '../network/sensor/sensor_api_service.dart';
import '../mappers/dto_mappers.dart';

/// Implementation of [ISensorRepository] that uses [SensorApiService].
class SensorRepositoryImpl implements ISensorRepository {
  final SensorApiService _sensorApiService;
  final Future<String> Function() _getAccessToken;

  SensorRepositoryImpl({
    required SensorApiService sensorApiService,
    required Future<String> Function() getAccessToken,
  }) : _sensorApiService = sensorApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<SensorEntity>>> getAllSensors({
    int? areaId,
    int? sensorTypeId,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getAll(
        accessToken: token,
        areaId: areaId,
        sensorTypeId: sensorTypeId,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => _shortenToSensorEntity(dto)).toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all sensors: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<SensorEntity>>> getSensorList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? areaId,
    int? sensorTypeId,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        name: name,
        areaId: areaId,
        sensorTypeId: sensorTypeId,
        status: status != null ? _mapIntToCommonStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<SensorEntity>(
                data: [],
                currentPage: page,
                pageSize: pageSize,
                totalRecords: 0,
                totalPages: 0,
              ),
            );
          }
          final entities = response.data.map((dto) => dto.toEntity()).toList();
          return Right(
            PagingResponse(
              data: entities,
              currentPage: response.currentPage,
              pageSize: response.pageSize,
              totalRecords: response.totalRecords,
              totalPages: response.totalPages,
            ),
          );
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get sensor list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorEntity>> getSensorById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Sensor not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get sensor by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorEntity>> createSensor(
    SensorEntity sensor,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = sensor.toDto();
      final result = await _sensorApiService.create(
        sensor: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to create sensor'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create sensor: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorEntity>> updateSensor(
    int id,
    SensorEntity sensor,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = sensor.toDto();
      final result = await _sensorApiService.update(
        id: id,
        sensor: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to update sensor'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update sensor: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteSensor(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.delete(id: id, accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete sensor: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor Type Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<SensorTypeEntity>>> getAllSensorTypes({
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getAllTypes(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response
                  ?.map((dto) => _shortenToSensorTypeEntity(dto))
                  .toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all sensor types: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<SensorTypeEntity>>> getSensorTypeList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getTypeList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        status: status != null ? _mapIntToCommonStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<SensorTypeEntity>(
                data: [],
                currentPage: page,
                pageSize: pageSize,
                totalRecords: 0,
                totalPages: 0,
              ),
            );
          }
          final entities = response.data.map((dto) => dto.toEntity()).toList();
          return Right(
            PagingResponse(
              data: entities,
              currentPage: response.currentPage,
              pageSize: response.pageSize,
              totalRecords: response.totalRecords,
              totalPages: response.totalPages,
            ),
          );
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get sensor type list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorTypeEntity>> getSensorTypeById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.getTypeById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Sensor type not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get sensor type by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorTypeEntity>> createSensorType(
    SensorTypeEntity sensorType,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = sensorType.toDto();
      final result = await _sensorApiService.createType(
        sensorType: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to create sensor type'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create sensor type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, SensorTypeEntity>> updateSensorType(
    int id,
    SensorTypeEntity sensorType,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = sensorType.toDto();
      final result = await _sensorApiService.updateType(
        id: id,
        sensorType: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to update sensor type'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update sensor type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteSensorType(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _sensorApiService.deleteType(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete sensor type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  CommonStatus? _mapIntToCommonStatus(int status) {
    switch (status) {
      case 0:
        return CommonStatus.inactive;
      case 1:
        return CommonStatus.active;
      default:
        return null;
    }
  }

  SensorEntity _shortenToSensorEntity(ShortenBaseDto dto) {
    return SensorEntity(id: dto.id, name: dto.name);
  }

  SensorTypeEntity _shortenToSensorTypeEntity(ShortenBaseDto dto) {
    return SensorTypeEntity(id: dto.id, name: dto.name);
  }
}
