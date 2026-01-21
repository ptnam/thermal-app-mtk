/// =============================================================================
/// File: sensor_type_dto.dart
/// Description: Sensor Type data transfer object
/// 
/// Purpose:
/// - Maps to backend's SensorTypeDto model
/// - Used for sensor type management
/// =============================================================================

import '../../core/base_dto.dart';

/// Sensor Type DTO
class SensorTypeDto {
  final int? id;
  final String? name;
  final String? description;
  final CommonStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SensorTypeDto({
    this.id,
    this.name,
    this.description,
    this.status = CommonStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  factory SensorTypeDto.fromJson(Map<String, dynamic> json) {
    return SensorTypeDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      'status': status.value,
    };
  }

  SensorTypeDto copyWith({
    int? id,
    String? name,
    String? description,
    CommonStatus? status,
  }) {
    return SensorTypeDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
