abstract class GridEvent {}

class TickSimulation extends GridEvent {}

class UpdateWindSpeed extends GridEvent {
  final int turbineId;
  final double value;
  UpdateWindSpeed(this.turbineId, this.value);
}

class UpdateBladeAngle extends GridEvent {
  final int turbineId;
  final double value;
  UpdateBladeAngle(this.turbineId, this.value);
}

class ToggleMaintenance extends GridEvent {
  final int turbineId;
  ToggleMaintenance(this.turbineId);
}

class ShutdownTurbine extends GridEvent {
  final int turbineId;
  ShutdownTurbine(this.turbineId);
}

class ResetTurbine extends GridEvent {
  final int turbineId;
  ResetTurbine(this.turbineId);
}

// Environmental presets
class ApplyPreset extends GridEvent {
  final EnvironmentPreset preset;
  ApplyPreset(this.preset);
}

enum EnvironmentPreset { calmDay, stormWarning, gridPeak }
