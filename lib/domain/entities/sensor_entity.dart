/// =============================================================================
/// File: sensor_entity.dart
/// Description: Sensor domain entities
/// 
/// Purpose:
/// - Pure domain models for sensor and sensor type
/// - Used in temperature monitoring features
/// =============================================================================

import 'machine_entity.dart';

/// Domain entity representing a Sensor Type
class SensorTypeEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String? manufacturer;
  final EntityStatus status;

  const SensorTypeEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.manufacturer,
    this.status = EntityStatus.active,
  });

  bool get isActive => status == EntityStatus.active;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorTypeEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Domain entity representing a Sensor
class SensorEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final int? sensorTypeId;
  final String? sensorTypeName;
  final SensorTypeEntity? sensorType;
  final String? ipAddress;
  final int? port;
  final EntityStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SensorEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.sensorTypeId,
    this.sensorTypeName,
    this.sensorType,
    this.ipAddress,
    this.port,
    this.status = EntityStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == EntityStatus.active;

  SensorEntity copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    int? sensorTypeId,
    String? sensorTypeName,
    SensorTypeEntity? sensorType,
    String? ipAddress,
    int? port,
    EntityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SensorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      sensorTypeId: sensorTypeId ?? this.sensorTypeId,
      sensorTypeName: sensorTypeName ?? this.sensorTypeName,
      sensorType: sensorType ?? this.sensorType,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SensorEntity(id: $id, name: $name)';
}
