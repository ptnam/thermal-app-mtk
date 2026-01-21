import 'package:camera_viewer/data/network/core/endpoints.dart';

/// =============================================================================
/// File: sensor_endpoints.dart
/// Description: API endpoint definitions for Sensor operations
/// 
/// Purpose:
/// - Centralized endpoint management for Sensor and SensorType APIs
/// - Clean separation of URL construction logic
/// =============================================================================

/// Sensor API endpoints
class SensorEndpoints extends Endpoints {
  SensorEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all sensors (shortened list)
  /// Query params: areaId, sensorTypeId
  String get all => path('/api/Sensors/all');

  /// GET: Get paginated sensor list
  /// Query params: page, pageSize, areaId, sensorTypeId, monitorType, name, status
  String get list => path('/api/Sensors/list');

  /// GET: Get sensor by ID
  String byId(int id) => path('/api/Sensors/$id');

  /// POST: Create new sensor
  String get create => path('/api/Sensors');

  /// PUT: Update sensor by ID
  String update(int id) => path('/api/Sensors/$id');

  /// DELETE: Delete sensor by ID
  String delete(int id) => path('/api/Sensors/$id');

  /// POST: Get sensors by areas (anonymous)
  String get sensorsByAreas => path('/api/Sensors/sensorsByAreas');
}

/// Sensor Type API endpoints
class SensorTypeEndpoints extends Endpoints {
  SensorTypeEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all sensor types (shortened list)
  String get all => path('/api/SensorTypes/all');

  /// GET: Get paginated sensor type list
  String get list => path('/api/SensorTypes/list');

  /// GET: Get sensor type by ID
  String byId(int id) => path('/api/SensorTypes/$id');

  /// POST: Create new sensor type
  String get create => path('/api/SensorTypes');

  /// PUT: Update sensor type by ID
  String update(int id) => path('/api/SensorTypes/$id');

  /// DELETE: Delete sensor type by ID
  String delete(int id) => path('/api/SensorTypes/$id');
}
