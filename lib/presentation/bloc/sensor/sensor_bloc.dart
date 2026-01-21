/// =============================================================================
/// File: sensor_bloc.dart
/// Description: BLoC for Sensor and Sensor Type management
///
/// Purpose:
/// - Handle sensor CRUD operations
/// - Handle sensor type CRUD operations
/// - Manage pagination and filters
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sensor_entity.dart';
import '../../../domain/repositories/sensor_repository.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

/// BLoC for Sensor and Sensor Type management.
///
/// Handles:
/// - Sensor list with pagination and filters
/// - Sensor CRUD operations
/// - Sensor Type CRUD operations
class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final ISensorRepository _sensorRepository;

  SensorBloc({required ISensorRepository sensorRepository})
    : _sensorRepository = sensorRepository,
      super(SensorState.initial()) {
    // Sensor events
    on<LoadAllSensorsEvent>(_onLoadAllSensors);
    on<LoadSensorListEvent>(_onLoadSensorList);
    on<LoadSensorByIdEvent>(_onLoadSensorById);
    on<CreateSensorEvent>(_onCreateSensor);
    on<UpdateSensorEvent>(_onUpdateSensor);
    on<DeleteSensorEvent>(_onDeleteSensor);

    // Sensor Type events
    on<LoadAllSensorTypesEvent>(_onLoadAllSensorTypes);
    on<LoadSensorTypeListEvent>(_onLoadSensorTypeList);
    on<CreateSensorTypeEvent>(_onCreateSensorType);
    on<UpdateSensorTypeEvent>(_onUpdateSensorType);
    on<DeleteSensorTypeEvent>(_onDeleteSensorType);

    // Filter & State events
    on<SensorFilterChangedEvent>(_onFilterChanged);
    on<ResetSensorOperationStatusEvent>(_onResetOperationStatus);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load all sensors (for dropdowns)
  Future<void> _onLoadAllSensors(
    LoadAllSensorsEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorListStatus: SensorStatus.loading));

    final result = await _sensorRepository.getAllSensors();

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorListStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (sensors) => emit(
        state.copyWith(
          sensorListStatus: SensorStatus.success,
          allSensors: sensors,
          clearError: true,
        ),
      ),
    );
  }

  /// Load paginated sensor list
  Future<void> _onLoadSensorList(
    LoadSensorListEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(
      state.copyWith(
        sensorListStatus: SensorStatus.loading,
        searchKeyword: event.searchKeyword,
        selectedAreaId: event.areaId,
        selectedSensorTypeId: event.sensorTypeId,
        statusFilter: event.status,
      ),
    );

    final result = await _sensorRepository.getSensorList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.searchKeyword,
      areaId: event.areaId,
      sensorTypeId: event.sensorTypeId,
      status: _parseStatus(event.status),
    );

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorListStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (pagingResponse) => emit(
        state.copyWith(
          sensorListStatus: SensorStatus.success,
          sensors: pagingResponse.data,
          currentPage: pagingResponse.currentPage,
          pageSize: pagingResponse.pageSize,
          totalRecords: pagingResponse.totalRecords,
          totalPages: pagingResponse.totalPages,
          clearError: true,
        ),
      ),
    );
  }

  /// Load sensor by ID
  Future<void> _onLoadSensorById(
    LoadSensorByIdEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorDetailStatus: SensorStatus.loading));

    final result = await _sensorRepository.getSensorById(event.id);

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorDetailStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (sensor) => emit(
        state.copyWith(
          sensorDetailStatus: SensorStatus.success,
          selectedSensor: sensor,
          clearError: true,
        ),
      ),
    );
  }

  /// Create new sensor
  Future<void> _onCreateSensor(
    CreateSensorEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorOperationStatus: SensorStatus.loading));

    final newSensor = SensorEntity(
      id: 0, // Will be assigned by backend
      name: event.name,
      code: event.code,
      description: event.description,
      areaId: event.areaId,
      sensorTypeId: event.sensorTypeId,
      ipAddress: event.ipAddress,
      port: event.port,
    );

    final result = await _sensorRepository.createSensor(newSensor);

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (createdSensor) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.success,
          operationResult: createdSensor,
          clearError: true,
        ),
      ),
    );
  }

  /// Update existing sensor
  Future<void> _onUpdateSensor(
    UpdateSensorEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorOperationStatus: SensorStatus.loading));

    final updatedSensor = SensorEntity(
      id: event.id,
      name: event.name ?? state.selectedSensor?.name ?? '',
      code: event.code ?? state.selectedSensor?.code,
      description: event.description ?? state.selectedSensor?.description,
      areaId: event.areaId ?? state.selectedSensor?.areaId,
      sensorTypeId: event.sensorTypeId ?? state.selectedSensor?.sensorTypeId,
      ipAddress: event.ipAddress ?? state.selectedSensor?.ipAddress,
      port: event.port ?? state.selectedSensor?.port,
    );

    final result = await _sensorRepository.updateSensor(
      event.id,
      updatedSensor,
    );

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (sensor) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.success,
          operationResult: sensor,
          selectedSensor: sensor,
          clearError: true,
        ),
      ),
    );
  }

  /// Delete sensor
  Future<void> _onDeleteSensor(
    DeleteSensorEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorOperationStatus: SensorStatus.loading));

    final result = await _sensorRepository.deleteSensor(event.id);

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          sensorOperationStatus: SensorStatus.success,
          clearError: true,
          clearSelectedSensor: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sensor Type Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load all sensor types
  Future<void> _onLoadAllSensorTypes(
    LoadAllSensorTypesEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorTypeListStatus: SensorStatus.loading));

    final result = await _sensorRepository.getAllSensorTypes();

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorTypeListStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (sensorTypes) => emit(
        state.copyWith(
          sensorTypeListStatus: SensorStatus.success,
          allSensorTypes: sensorTypes,
          clearError: true,
        ),
      ),
    );
  }

  /// Load paginated sensor type list
  Future<void> _onLoadSensorTypeList(
    LoadSensorTypeListEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorTypeListStatus: SensorStatus.loading));

    final result = await _sensorRepository.getSensorTypeList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.searchKeyword,
      status: _parseStatus(event.status),
    );

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorTypeListStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (pagingResponse) => emit(
        state.copyWith(
          sensorTypeListStatus: SensorStatus.success,
          sensorTypes: pagingResponse.data,
          sensorTypeCurrentPage: pagingResponse.currentPage,
          sensorTypeTotalRecords: pagingResponse.totalRecords,
          clearError: true,
        ),
      ),
    );
  }

  /// Create sensor type
  Future<void> _onCreateSensorType(
    CreateSensorTypeEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorTypeOperationStatus: SensorStatus.loading));

    final newSensorType = SensorTypeEntity(
      id: 0,
      name: event.name,
      description: event.description,
    );

    final result = await _sensorRepository.createSensorType(newSensorType);

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (createdType) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.success,
          typeOperationResult: createdType,
          clearError: true,
        ),
      ),
    );
  }

  /// Update sensor type
  Future<void> _onUpdateSensorType(
    UpdateSensorTypeEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorTypeOperationStatus: SensorStatus.loading));

    final updatedType = SensorTypeEntity(
      id: event.id,
      name: event.name ?? state.selectedSensorType?.name ?? '',
      description: event.description ?? state.selectedSensorType?.description,
    );

    final result = await _sensorRepository.updateSensorType(
      event.id,
      updatedType,
    );

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (sensorType) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.success,
          typeOperationResult: sensorType,
          selectedSensorType: sensorType,
          clearError: true,
        ),
      ),
    );
  }

  /// Delete sensor type
  Future<void> _onDeleteSensorType(
    DeleteSensorTypeEvent event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(sensorTypeOperationStatus: SensorStatus.loading));

    final result = await _sensorRepository.deleteSensorType(event.id);

    result.fold(
      (error) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          sensorTypeOperationStatus: SensorStatus.success,
          clearError: true,
          clearSelectedSensorType: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Filter & State Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handle filter changes
  void _onFilterChanged(
    SensorFilterChangedEvent event,
    Emitter<SensorState> emit,
  ) {
    emit(
      state.copyWith(
        searchKeyword: event.searchKeyword,
        selectedAreaId: event.areaId,
        selectedSensorTypeId: event.sensorTypeId,
        statusFilter: event.status,
      ),
    );

    // Trigger reload with new filters
    add(
      LoadSensorListEvent(
        searchKeyword: event.searchKeyword,
        areaId: event.areaId,
        sensorTypeId: event.sensorTypeId,
        status: event.status,
      ),
    );
  }

  /// Reset operation status
  void _onResetOperationStatus(
    ResetSensorOperationStatusEvent event,
    Emitter<SensorState> emit,
  ) {
    emit(
      state.copyWith(
        sensorOperationStatus: SensorStatus.initial,
        sensorTypeOperationStatus: SensorStatus.initial,
        clearOperationResult: true,
        clearTypeOperationResult: true,
        clearError: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Parse status string to int
  int? _parseStatus(String? status) {
    if (status == null || status.isEmpty) return null;
    if (status == 'active' || status == '1') return 1;
    if (status == 'inactive' || status == '0') return 0;
    return int.tryParse(status);
  }
}
