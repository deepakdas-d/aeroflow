import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../engine/simulation_engine.dart';
import '../models/grid_model.dart';
import '../models/turbine_model.dart';
import 'grid_event.dart';
import 'grid_state.dart';

class GridBloc extends Bloc<GridEvent, GridBlocState> {
  final SimulationEngine engine;
  Timer? timer;
  final List<double> _powerHistory = [];
  static const int maxHistoryLength = 60;

  static TurbineModel _defaultTurbine(int index) => TurbineModel(
        id: index,
        windSpeed: 40,
        bladeAngle: 20,
        maintenanceMode: false,
        shutdown: false,
        failed: false,
        stress: 10,
        powerOutput: 0,
        health: 100,
        temperature: 45,
        vibration: 5,
        rpm: 400,
      );

  GridBloc(this.engine)
      : super(
          GridBlocState(
            GridModel(
              turbines: List.generate(6, _defaultTurbine),
              totalMW: 0,
              stability: 100,
              gridFailure: false,
            ),
          ),
        ) {
    on<TickSimulation>(_onTick);
    on<UpdateWindSpeed>(_updateWind);
    on<UpdateBladeAngle>(_updateAngle);
    on<ToggleMaintenance>(_toggleMaintenance);
    on<ShutdownTurbine>(_shutdownTurbine);
    on<ResetTurbine>(_resetTurbine);
    on<ApplyPreset>(_applyPreset);

    timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => add(TickSimulation()),
    );
  }

  List<double> get powerHistory => List.unmodifiable(_powerHistory);

  void _onTick(TickSimulation event, Emitter<GridBlocState> emit) {
    final newGrid = engine.tick(state.grid);
    final newLogs = <String>[...state.eventLog];

    _powerHistory.add(newGrid.totalMW);
    if (_powerHistory.length > maxHistoryLength) {
      _powerHistory.removeAt(0);
    }

    for (int i = 0; i < newGrid.turbines.length; i++) {
      final old = state.grid.turbines[i];
      final cur = newGrid.turbines[i];

      if (!old.failed && cur.failed) {
        newLogs.insert(0, '[!!] CRITICAL: Turbine $i FAILED - stress overload');
      }
      if (cur.stress > 80 && old.stress <= 80) {
        newLogs.insert(0, '[!] WARNING: Turbine $i stress > 80%');
      }
      if (cur.temperature > 120 && old.temperature <= 120) {
        newLogs.insert(0, '[!] OVERHEAT: Turbine $i temp ${cur.temperature.toStringAsFixed(0)}C');
      }
    }

    if (!state.grid.gridFailure && newGrid.gridFailure) {
      newLogs.insert(0, '[!!!] GRID FAILURE - stability critical');
    }

    if (newLogs.length > 50) newLogs.removeRange(50, newLogs.length);

    emit(state.copyWith(grid: newGrid, eventLog: newLogs));
  }

  void _updateWind(UpdateWindSpeed event, Emitter<GridBlocState> emit) {
    final updated = [...state.grid.turbines];
    updated[event.turbineId] = updated[event.turbineId].copyWith(windSpeed: event.value);
    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated)));
  }

  void _updateAngle(UpdateBladeAngle event, Emitter<GridBlocState> emit) {
    final updated = [...state.grid.turbines];
    updated[event.turbineId] = updated[event.turbineId].copyWith(bladeAngle: event.value);
    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated)));
  }

  void _toggleMaintenance(ToggleMaintenance event, Emitter<GridBlocState> emit) {
    final updated = [...state.grid.turbines];
    final t = updated[event.turbineId];
    updated[event.turbineId] = t.copyWith(maintenanceMode: !t.maintenanceMode);
    final newLogs = <String>[...state.eventLog];
    newLogs.insert(0, t.maintenanceMode
        ? '[+] Turbine ${event.turbineId} back online'
        : '[M] Turbine ${event.turbineId} entered maintenance');
    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated), eventLog: newLogs));
  }

  void _shutdownTurbine(ShutdownTurbine event, Emitter<GridBlocState> emit) {
    final updated = [...state.grid.turbines];
    final t = updated[event.turbineId];
    updated[event.turbineId] = t.copyWith(shutdown: !t.shutdown);
    final newLogs = <String>[...state.eventLog];
    newLogs.insert(0, t.shutdown
        ? '[+] Turbine ${event.turbineId} restarted'
        : '[X] Turbine ${event.turbineId} shut down');
    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated), eventLog: newLogs));
  }

  void _resetTurbine(ResetTurbine event, Emitter<GridBlocState> emit) {
    final updated = [...state.grid.turbines];
    updated[event.turbineId] = _defaultTurbine(event.turbineId);
    final newLogs = <String>[...state.eventLog];
    newLogs.insert(0, '[R] Turbine ${event.turbineId} reset');
    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated), eventLog: newLogs));
  }

  void _applyPreset(ApplyPreset event, Emitter<GridBlocState> emit) {
    final updated = state.grid.turbines.map((t) {
      if (t.failed) return t;
      switch (event.preset) {
        case EnvironmentPreset.calmDay:
          return t.copyWith(windSpeed: 20, bladeAngle: 15);
        case EnvironmentPreset.stormWarning:
          return t.copyWith(windSpeed: 90, bladeAngle: 60);
        case EnvironmentPreset.gridPeak:
          return t.copyWith(windSpeed: 70, bladeAngle: 35);
      }
    }).toList();

    final label = switch (event.preset) {
      EnvironmentPreset.calmDay => 'Calm Day',
      EnvironmentPreset.stormWarning => 'Storm Warning',
      EnvironmentPreset.gridPeak => 'Grid Peak',
    };

    final newLogs = <String>[...state.eventLog];
    newLogs.insert(0, '[ENV] Preset applied: $label');

    emit(state.copyWith(grid: state.grid.copyWith(turbines: updated), eventLog: newLogs));
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
