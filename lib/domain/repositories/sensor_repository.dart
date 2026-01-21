/// =============================================================================
/// File: sensor_repository.dart
/// Description: Sensor repository interface
/// 
/// Purpose:
/// - Define contract for sensor and sensor type operations
/// - Support temperature sensor management
/// =============================================================================

import 'package:dartz/dartz.dart';

import '../../data/network/core/api_error.dart';
import '../../data/network/core/paging_response.dart';
import '../entities/sensor_entity.dart';

/// Repository interface for Sensor operations
abstract class ISensorRepository {
  // ─────────────────────────────────────────────────────────────────────────
  // Sensor Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all sensors (for dropdowns)
  Future<Either<ApiError, List<SensorEntity>>> getAllSensors({
    int? areaId,
    int? sensorTypeId,
    int? status,
  });

  /// Get paginated sensor list
  Future<Either<ApiError, PagingResponse<SensorEntity>>> getSensorList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? areaId,
    int? sensorTypeId,
    int? status,
  });

  /// Get sensor by ID
  Future<Either<ApiError, SensorEntity>> getSensorById(int id);

  /// Create new sensor
  Future<Either<ApiError, SensorEntity>> createSensor(SensorEntity sensor);

  /// Update sensor
  Future<Either<ApiError, SensorEntity>> updateSensor(int id, SensorEntity sensor);

  /// Delete sensor
  Future<Either<ApiError, void>> deleteSensor(int id);

  // ─────────────────────────────────────────────────────────────────────────
  // Sensor Type Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all sensor types
  Future<Either<ApiError, List<SensorTypeEntity>>> getAllSensorTypes({
    int? status,
  });

  /// Get paginated sensor type list
  Future<Either<ApiError, PagingResponse<SensorTypeEntity>>> getSensorTypeList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  });

  /// Get sensor type by ID
  Future<Either<ApiError, SensorTypeEntity>> getSensorTypeById(int id);

  /// Create sensor type
  Future<Either<ApiError, SensorTypeEntity>> createSensorType(SensorTypeEntity sensorType);

  /// Update sensor type
  Future<Either<ApiError, SensorTypeEntity>> updateSensorType(int id, SensorTypeEntity sensorType);

  /// Delete sensor type
  Future<Either<ApiError, void>> deleteSensorType(int id);
}
