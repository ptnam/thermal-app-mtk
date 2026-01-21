/// =============================================================================
/// File: sensor_dto.dart
/// Description: Sensor data transfer objects for Sensor API
/// 
/// Purpose:
/// - Maps to backend's SensorDto model
/// - Used for sensor CRUD operations
/// - Contains sensor and monitor point information
/// =============================================================================

import '../../core/base_dto.dart';

/// Helper to parse int from String or int
int? _parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Sensor DTO for full sensor information
/// Maps to backend's SensorDto model
class SensorDto {
  final int? id;
  final String? name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final int? sensorTypeId;
  final String? sensorTypeName;
  final MonitorType? monitorType;
  final CommonStatus status;
  final String? ipAddress;
  final int? port;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? monitorPoints;

  const SensorDto({
    this.id,
    this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.sensorTypeId,
    this.sensorTypeName,
    this.monitorType,
    this.status = CommonStatus.active,
    this.ipAddress,
    this.port,
    this.createdAt,
    this.updatedAt,
    this.monitorPoints,
  });

  factory SensorDto.fromJson(Map<String, dynamic> json) {
    return SensorDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      areaId: json['areaId'] as int?,
      areaName: json['areaName'] as String?,
      sensorTypeId: json['sensorTypeId'] as int?,
      sensorTypeName: json['sensorTypeName'] as String?,
      monitorType: json['monitorType'] != null
          ? MonitorType.fromValue(_parseIntOrNull(json['monitorType']) ?? 0)
          : null,
      status: CommonStatus.fromValue(_parseIntOrNull(json['status']) ?? 1),
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      monitorPoints: json['monitorPoints'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (areaId != null) 'areaId': areaId,
      if (sensorTypeId != null) 'sensorTypeId': sensorTypeId,
      if (monitorType != null) 'monitorType': monitorType!.value,
      'status': status.value,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (port != null) 'port': port,
    };
  }

  SensorDto copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    int? sensorTypeId,
    String? sensorTypeName,
    MonitorType? monitorType,
    CommonStatus? status,
    String? ipAddress,
    int? port,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<dynamic>? monitorPoints,
  }) {
    return SensorDto(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      sensorTypeId: sensorTypeId ?? this.sensorTypeId,
      sensorTypeName: sensorTypeName ?? this.sensorTypeName,
      monitorType: monitorType ?? this.monitorType,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      monitorPoints: monitorPoints ?? this.monitorPoints,
    );
  }
}

/// Request DTO for fetching sensors by areas
class SensorInfoRequest {
  final List<int> areaIds;
  final String token;
  final MonitorType? monitorType;
  final int? sensorType;

  const SensorInfoRequest({
    required this.areaIds,
    required this.token,
    this.monitorType,
    this.sensorType,
  });

  Map<String, dynamic> toJson() {
    return {
      'areaIds': areaIds,
      'token': token,
      if (monitorType != null) 'monitorType': monitorType!.value,
      if (sensorType != null) 'sensorType': sensorType,
    };
  }
}
