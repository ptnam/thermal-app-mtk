import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_viewer/domain/entities/area_tree.dart';
import 'package:camera_viewer/data/local/area_preferences.dart';

/// Events
abstract class AreaSelectionEvent {
  const AreaSelectionEvent();
}

class LoadSelectedAreaEvent extends AreaSelectionEvent {
  const LoadSelectedAreaEvent();
}

class SelectAreaEvent extends AreaSelectionEvent {
  final AreaTree area;
  const SelectAreaEvent(this.area);
}

class ClearSelectedAreaEvent extends AreaSelectionEvent {
  const ClearSelectedAreaEvent();
}

/// State
class AreaSelectionState {
  final AreaTree? selectedArea;
  final bool isLoading;
  final bool hasSelectedArea;
  final String? errorMessage;

  const AreaSelectionState({
    this.selectedArea,
    this.isLoading = false,
    this.hasSelectedArea = false,
    this.errorMessage,
  });

  AreaSelectionState copyWith({
    AreaTree? selectedArea,
    bool? isLoading,
    bool? hasSelectedArea,
    String? errorMessage,
  }) {
    return AreaSelectionState(
      selectedArea: selectedArea ?? this.selectedArea,
      isLoading: isLoading ?? this.isLoading,
      hasSelectedArea: hasSelectedArea ?? this.hasSelectedArea,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// BLoC quản lý việc chọn khu vực
class AreaSelectionBloc extends Bloc<AreaSelectionEvent, AreaSelectionState> {
  final AreaPreferences _areaPreferences;

  AreaSelectionBloc({required AreaPreferences areaPreferences})
    : _areaPreferences = areaPreferences,
      super(const AreaSelectionState()) {
    on<LoadSelectedAreaEvent>(_onLoadSelectedArea);
    on<SelectAreaEvent>(_onSelectArea);
    on<ClearSelectedAreaEvent>(_onClearSelectedArea);
  }

  Future<void> _onLoadSelectedArea(
    LoadSelectedAreaEvent event,
    Emitter<AreaSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final savedArea = await _areaPreferences.getSelectedArea();
      if (savedArea != null) {
        emit(
          state.copyWith(
            selectedArea: savedArea,
            hasSelectedArea: true,
            isLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(hasSelectedArea: false, isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectArea(
    SelectAreaEvent event,
    Emitter<AreaSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _areaPreferences.saveSelectedArea(event.area);
      emit(
        state.copyWith(
          selectedArea: event.area,
          hasSelectedArea: true,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearSelectedArea(
    ClearSelectedAreaEvent event,
    Emitter<AreaSelectionState> emit,
  ) async {
    await _areaPreferences.clearSelectedArea();
    emit(
      const AreaSelectionState(
        selectedArea: null,
        hasSelectedArea: false,
        isLoading: false,
      ),
    );
  }
}
