/// =============================================================================
/// File: sensor_state.dart
/// Description: State for SensorBloc
/// =============================================================================

import 'package:equatable/equatable.dart';

import '../../../domain/entities/sensor_entity.dart';

/// Status for async operations in SensorBloc.
enum SensorStatus {
  initial,
  loading,
  success,
  failure,
}

/// State for SensorBloc.
class SensorState extends Equatable {
  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor State
  // ─────────────────────────────────────────────────────────────────────────────

  /// All sensors (for dropdowns).
  final List<SensorEntity> allSensors;

  /// Paginated sensor list.
  final List<SensorEntity> sensors;

  /// Currently selected/viewed sensor.
  final SensorEntity? selectedSensor;

  /// Status for sensor list operations.
  final SensorStatus sensorListStatus;

  /// Status for sensor detail operations.
  final SensorStatus sensorDetailStatus;

  /// Status for sensor CRUD operations.
  final SensorStatus sensorOperationStatus;

  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor Type State
  // ─────────────────────────────────────────────────────────────────────────────

  /// All sensor types (for dropdowns).
  final List<SensorTypeEntity> allSensorTypes;

  /// Paginated sensor type list.
  final List<SensorTypeEntity> sensorTypes;

  /// Currently selected sensor type.
  final SensorTypeEntity? selectedSensorType;

  /// Status for sensor type list operations.
  final SensorStatus sensorTypeListStatus;

  /// Status for sensor type CRUD operations.
  final SensorStatus sensorTypeOperationStatus;

  // ─────────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────────

  /// Current page for sensor list.
  final int currentPage;

  /// Page size.
  final int pageSize;

  /// Total sensor records.
  final int totalRecords;

  /// Total pages.
  final int totalPages;

  /// Current page for sensor type list.
  final int sensorTypeCurrentPage;

  /// Total sensor type records.
  final int sensorTypeTotalRecords;

  // ─────────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────────

  /// Search keyword filter.
  final String? searchKeyword;

  /// Area filter.
  final int? selectedAreaId;

  /// Sensor type filter.
  final int? selectedSensorTypeId;

  /// Status filter.
  final String? statusFilter;

  // ─────────────────────────────────────────────────────────────────────────────
  // Error & Operation Result
  // ─────────────────────────────────────────────────────────────────────────────

  /// Error message when operation fails.
  final String? errorMessage;

  /// Result of last CRUD operation (sensor).
  final SensorEntity? operationResult;

  /// Result of last CRUD operation (sensor type).
  final SensorTypeEntity? typeOperationResult;

  const SensorState({
    this.allSensors = const [],
    this.sensors = const [],
    this.selectedSensor,
    this.sensorListStatus = SensorStatus.initial,
    this.sensorDetailStatus = SensorStatus.initial,
    this.sensorOperationStatus = SensorStatus.initial,
    this.allSensorTypes = const [],
    this.sensorTypes = const [],
    this.selectedSensorType,
    this.sensorTypeListStatus = SensorStatus.initial,
    this.sensorTypeOperationStatus = SensorStatus.initial,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.sensorTypeCurrentPage = 1,
    this.sensorTypeTotalRecords = 0,
    this.searchKeyword,
    this.selectedAreaId,
    this.selectedSensorTypeId,
    this.statusFilter,
    this.errorMessage,
    this.operationResult,
    this.typeOperationResult,
  });

  /// Initial state factory.
  factory SensorState.initial() => const SensorState();

  /// Creates a copy of this state with specified fields replaced.
  SensorState copyWith({
    List<SensorEntity>? allSensors,
    List<SensorEntity>? sensors,
    SensorEntity? selectedSensor,
    SensorStatus? sensorListStatus,
    SensorStatus? sensorDetailStatus,
    SensorStatus? sensorOperationStatus,
    List<SensorTypeEntity>? allSensorTypes,
    List<SensorTypeEntity>? sensorTypes,
    SensorTypeEntity? selectedSensorType,
    SensorStatus? sensorTypeListStatus,
    SensorStatus? sensorTypeOperationStatus,
    int? currentPage,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
    int? sensorTypeCurrentPage,
    int? sensorTypeTotalRecords,
    String? searchKeyword,
    int? selectedAreaId,
    int? selectedSensorTypeId,
    String? statusFilter,
    String? errorMessage,
    SensorEntity? operationResult,
    SensorTypeEntity? typeOperationResult,
    bool clearSelectedSensor = false,
    bool clearSelectedSensorType = false,
    bool clearOperationResult = false,
    bool clearTypeOperationResult = false,
    bool clearError = false,
  }) {
    return SensorState(
      allSensors: allSensors ?? this.allSensors,
      sensors: sensors ?? this.sensors,
      selectedSensor: clearSelectedSensor ? null : (selectedSensor ?? this.selectedSensor),
      sensorListStatus: sensorListStatus ?? this.sensorListStatus,
      sensorDetailStatus: sensorDetailStatus ?? this.sensorDetailStatus,
      sensorOperationStatus: sensorOperationStatus ?? this.sensorOperationStatus,
      allSensorTypes: allSensorTypes ?? this.allSensorTypes,
      sensorTypes: sensorTypes ?? this.sensorTypes,
      selectedSensorType: clearSelectedSensorType ? null : (selectedSensorType ?? this.selectedSensorType),
      sensorTypeListStatus: sensorTypeListStatus ?? this.sensorTypeListStatus,
      sensorTypeOperationStatus: sensorTypeOperationStatus ?? this.sensorTypeOperationStatus,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      sensorTypeCurrentPage: sensorTypeCurrentPage ?? this.sensorTypeCurrentPage,
      sensorTypeTotalRecords: sensorTypeTotalRecords ?? this.sensorTypeTotalRecords,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedSensorTypeId: selectedSensorTypeId ?? this.selectedSensorTypeId,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      operationResult: clearOperationResult ? null : (operationResult ?? this.operationResult),
      typeOperationResult: clearTypeOperationResult ? null : (typeOperationResult ?? this.typeOperationResult),
    );
  }

  @override
  List<Object?> get props => [
        allSensors,
        sensors,
        selectedSensor,
        sensorListStatus,
        sensorDetailStatus,
        sensorOperationStatus,
        allSensorTypes,
        sensorTypes,
        selectedSensorType,
        sensorTypeListStatus,
        sensorTypeOperationStatus,
        currentPage,
        pageSize,
        totalRecords,
        totalPages,
        sensorTypeCurrentPage,
        sensorTypeTotalRecords,
        searchKeyword,
        selectedAreaId,
        selectedSensorTypeId,
        statusFilter,
        errorMessage,
        operationResult,
        typeOperationResult,
      ];
}
