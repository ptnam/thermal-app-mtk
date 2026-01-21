/// =============================================================================
/// File: warning_event_dto.dart
/// Description: Warning Event data transfer object
/// 
/// Purpose:
/// - Maps to backend's WarningEventDto model
/// - Used for warning event management
/// =============================================================================

import '../../core/base_dto.dart';

/// Warning Event DTO
class WarningEventDto {
  final int? id;
  final String? name;
  final String? description;
  final WarningType? warningType;
  final CommonStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WarningEventDto({
    this.id,
    this.name,
    this.description,
    this.warningType,
    this.status = CommonStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  factory WarningEventDto.fromJson(Map<String, dynamic> json) {
    return WarningEventDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      warningType: json['warningType'] != null
          ? WarningType.fromValue(json['warningType'] as int)
          : null,
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
      if (warningType != null) 'warningType': warningType!.value,
      'status': status.value,
    };
  }

  WarningEventDto copyWith({
    int? id,
    String? name,
    String? description,
    WarningType? warningType,
    CommonStatus? status,
  }) {
    return WarningEventDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      warningType: warningType ?? this.warningType,
      status: status ?? this.status,
    );
  }
}
