/// =============================================================================
/// File: sensor_event.dart
/// Description: Events for SensorBloc
/// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all sensor events.
abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Sensor Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to load all sensors (dropdown/selection list).
class LoadAllSensorsEvent extends SensorEvent {
  const LoadAllSensorsEvent();
}

/// Event to load sensor list with pagination and filters.
class LoadSensorListEvent extends SensorEvent {
  final int page;
  final int pageSize;
  final String? searchKeyword;
  final int? areaId;
  final int? sensorTypeId;
  final String? status;

  const LoadSensorListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.searchKeyword,
    this.areaId,
    this.sensorTypeId,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, searchKeyword, areaId, sensorTypeId, status];
}

/// Event to load a specific sensor by ID.
class LoadSensorByIdEvent extends SensorEvent {
  final int id;

  const LoadSensorByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to create a new sensor.
class CreateSensorEvent extends SensorEvent {
  final String name;
  final String? code;
  final String? description;
  final int? areaId;
  final int? sensorTypeId;
  final String? ipAddress;
  final int? port;

  const CreateSensorEvent({
    required this.name,
    this.code,
    this.description,
    this.areaId,
    this.sensorTypeId,
    this.ipAddress,
    this.port,
  });

  @override
  List<Object?> get props => [name, code, description, areaId, sensorTypeId, ipAddress, port];
}

/// Event to update an existing sensor.
class UpdateSensorEvent extends SensorEvent {
  final int id;
  final String? name;
  final String? code;
  final String? description;
  final int? areaId;
  final int? sensorTypeId;
  final String? ipAddress;
  final int? port;
  final String? status;

  const UpdateSensorEvent({
    required this.id,
    this.name,
    this.code,
    this.description,
    this.areaId,
    this.sensorTypeId,
    this.ipAddress,
    this.port,
    this.status,
  });

  @override
  List<Object?> get props => [id, name, code, description, areaId, sensorTypeId, ipAddress, port, status];
}

/// Event to delete a sensor.
class DeleteSensorEvent extends SensorEvent {
  final int id;

  const DeleteSensorEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────────────────
// Sensor Type Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to load all sensor types.
class LoadAllSensorTypesEvent extends SensorEvent {
  const LoadAllSensorTypesEvent();
}

/// Event to load sensor type list with pagination.
class LoadSensorTypeListEvent extends SensorEvent {
  final int page;
  final int pageSize;
  final String? searchKeyword;
  final String? status;

  const LoadSensorTypeListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.searchKeyword,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, searchKeyword, status];
}

/// Event to create a new sensor type.
class CreateSensorTypeEvent extends SensorEvent {
  final String name;
  final String? code;
  final String? description;
  final String? manufacturer;

  const CreateSensorTypeEvent({
    required this.name,
    this.code,
    this.description,
    this.manufacturer,
  });

  @override
  List<Object?> get props => [name, code, description, manufacturer];
}

/// Event to update a sensor type.
class UpdateSensorTypeEvent extends SensorEvent {
  final int id;
  final String? name;
  final String? code;
  final String? description;
  final String? manufacturer;
  final String? status;

  const UpdateSensorTypeEvent({
    required this.id,
    this.name,
    this.code,
    this.description,
    this.manufacturer,
    this.status,
  });

  @override
  List<Object?> get props => [id, name, code, description, manufacturer, status];
}

/// Event to delete a sensor type.
class DeleteSensorTypeEvent extends SensorEvent {
  final int id;

  const DeleteSensorTypeEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter & State Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to change sensor filters.
class SensorFilterChangedEvent extends SensorEvent {
  final String? searchKeyword;
  final int? areaId;
  final int? sensorTypeId;
  final String? status;

  const SensorFilterChangedEvent({
    this.searchKeyword,
    this.areaId,
    this.sensorTypeId,
    this.status,
  });

  @override
  List<Object?> get props => [searchKeyword, areaId, sensorTypeId, status];
}

/// Event to reset operation status after showing result.
class ResetSensorOperationStatusEvent extends SensorEvent {
  const ResetSensorOperationStatusEvent();
}
