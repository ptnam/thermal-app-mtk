/// =============================================================================
/// File: monitor_point_dto.dart
/// Description: Monitor Point data transfer objects
/// 
/// Purpose:
/// - Maps to backend's MonitorPoint DTOs
/// - Used for camera and sensor monitor point management
/// =============================================================================

import '../../core/base_dto.dart';

/// Camera Monitor Point extend DTO
class CameraMonitorPointExtendDto {
  final int? id;
  final String? name;
  final int? cameraId;
  final String? cameraName;
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final double? positionX;
  final double? positionY;
  final double? width;
  final double? height;
  final CommonStatus status;

  const CameraMonitorPointExtendDto({
    this.id,
    this.name,
    this.cameraId,
    this.cameraName,
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.status = CommonStatus.active,
  });

  factory CameraMonitorPointExtendDto.fromJson(Map<String, dynamic> json) {
    return CameraMonitorPointExtendDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      cameraId: json['cameraId'] as int?,
      cameraName: json['cameraName'] as String?,
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      machineComponentId: json['machineComponentId'] as int?,
      machineComponentName: json['machineComponentName'] as String?,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cameraId != null) 'cameraId': cameraId,
      if (machineId != null) 'machineId': machineId,
      if (machineComponentId != null) 'machineComponentId': machineComponentId,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'status': status.value,
    };
  }
}

/// Sensor Monitor Point extend DTO
class SensorMonitorPointExtendDto {
  final int? id;
  final String? name;
  final int? sensorId;
  final String? sensorName;
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final String? address;
  final CommonStatus status;

  const SensorMonitorPointExtendDto({
    this.id,
    this.name,
    this.sensorId,
    this.sensorName,
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.address,
    this.status = CommonStatus.active,
  });

  factory SensorMonitorPointExtendDto.fromJson(Map<String, dynamic> json) {
    return SensorMonitorPointExtendDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      sensorId: json['sensorId'] as int?,
      sensorName: json['sensorName'] as String?,
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      machineComponentId: json['machineComponentId'] as int?,
      machineComponentName: json['machineComponentName'] as String?,
      address: json['address'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sensorId != null) 'sensorId': sensorId,
      if (machineId != null) 'machineId': machineId,
      if (machineComponentId != null) 'machineComponentId': machineComponentId,
      if (address != null) 'address': address,
      'status': status.value,
    };
  }
}

/// General Monitor Point DTO (for mixed camera/sensor)
class GeneralMonitorPointDto {
  final int? id;
  final String? name;
  final MonitorPointType? type;
  final int? sourceId;
  final String? sourceName;
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final CommonStatus status;

  const GeneralMonitorPointDto({
    this.id,
    this.name,
    this.type,
    this.sourceId,
    this.sourceName,
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.status = CommonStatus.active,
  });

  factory GeneralMonitorPointDto.fromJson(Map<String, dynamic> json) {
    return GeneralMonitorPointDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      type: json['type'] != null
          ? MonitorPointType.fromValue(json['type'] as int)
          : null,
      sourceId: json['sourceId'] as int?,
      sourceName: json['sourceName'] as String?,
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      machineComponentId: json['machineComponentId'] as int?,
      machineComponentName: json['machineComponentName'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
    );
  }
}
