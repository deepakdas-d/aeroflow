import 'package:equatable/equatable.dart';

class TurbineModel extends Equatable {
  final int id;
  final double windSpeed;
  final double bladeAngle;
  final bool maintenanceMode;
  final bool shutdown;
  final bool failed;
  final double stress;
  final double powerOutput;
  final double health;
  // Sensor sub-state
  final double temperature;
  final double vibration;
  final double rpm;

  const TurbineModel({
    required this.id,
    required this.windSpeed,
    required this.bladeAngle,
    required this.maintenanceMode,
    required this.shutdown,
    required this.failed,
    required this.stress,
    required this.powerOutput,
    required this.health,
    required this.temperature,
    required this.vibration,
    required this.rpm,
  });

  bool get isOffline => failed || shutdown || maintenanceMode;

  String get statusLabel {
    if (failed) return 'FAILED';
    if (shutdown) return 'OFFLINE';
    if (maintenanceMode) return 'MAINTENANCE';
    if (stress > 80) return 'CRITICAL';
    if (stress > 50) return 'WARNING';
    return 'OPTIMAL';
  }

  TurbineModel copyWith({
    double? windSpeed,
    double? bladeAngle,
    bool? maintenanceMode,
    bool? shutdown,
    bool? failed,
    double? stress,
    double? powerOutput,
    double? health,
    double? temperature,
    double? vibration,
    double? rpm,
  }) {
    return TurbineModel(
      id: id,
      windSpeed: windSpeed ?? this.windSpeed,
      bladeAngle: bladeAngle ?? this.bladeAngle,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      shutdown: shutdown ?? this.shutdown,
      failed: failed ?? this.failed,
      stress: stress ?? this.stress,
      powerOutput: powerOutput ?? this.powerOutput,
      health: health ?? this.health,
      temperature: temperature ?? this.temperature,
      vibration: vibration ?? this.vibration,
      rpm: rpm ?? this.rpm,
    );
  }

  @override
  List<Object?> get props => [
        id, windSpeed, bladeAngle, maintenanceMode, shutdown,
        failed, stress, powerOutput, health, temperature, vibration, rpm,
      ];
}
