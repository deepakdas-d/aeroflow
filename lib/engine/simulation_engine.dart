import 'dart:math';
import '../models/grid_model.dart';
import '../models/turbine_model.dart';

class SimulationEngine {
  final Random random = Random();

  GridModel tick(GridModel current) {
    final updatedTurbines = current.turbines.map((t) {
      return _updateTurbine(t);
    }).toList();

    // Cascading failures: failed turbines add stress to neighbors
    for (int i = 0; i < updatedTurbines.length; i++) {
      if (updatedTurbines[i].failed) {
        // Stress neighbors (i-1 and i+1)
        if (i > 0 && !updatedTurbines[i - 1].isOffline) {
          updatedTurbines[i - 1] = updatedTurbines[i - 1].copyWith(
            stress: (updatedTurbines[i - 1].stress + 1.5).clamp(0, 120),
          );
        }
        if (i < updatedTurbines.length - 1 && !updatedTurbines[i + 1].isOffline) {
          updatedTurbines[i + 1] = updatedTurbines[i + 1].copyWith(
            stress: (updatedTurbines[i + 1].stress + 1.5).clamp(0, 120),
          );
        }
      }
    }

    // Recheck failures after cascading
    for (int i = 0; i < updatedTurbines.length; i++) {
      if (updatedTurbines[i].stress > 100 && !updatedTurbines[i].failed) {
        updatedTurbines[i] = updatedTurbines[i].copyWith(
          failed: true,
          powerOutput: 0,
          health: 0,
        );
      }
    }

    final totalMW = updatedTurbines.fold(0.0, (sum, t) => sum + t.powerOutput);
    final avgStress = updatedTurbines.fold(0.0, (sum, t) => sum + t.stress) /
        updatedTurbines.length;
    final failedCount = updatedTurbines.where((e) => e.failed).length;
    final stability = (100 - avgStress - (failedCount * 15)).clamp(0, 100).toDouble();
    final gridFailure = stability < 25;

    return current.copyWith(
      turbines: updatedTurbines,
      totalMW: totalMW,
      stability: stability,
      gridFailure: gridFailure,
    );
  }

  TurbineModel _updateTurbine(TurbineModel t) {
    if (t.shutdown) {
      return t.copyWith(
        powerOutput: 0,
        stress: (t.stress - 1).clamp(0, 100),
        temperature: (t.temperature - 2).clamp(20, 200),
        vibration: 0,
        rpm: 0,
      );
    }

    if (t.maintenanceMode) {
      return t.copyWith(
        stress: (t.stress - 2).clamp(0, 100),
        powerOutput: 0,
        temperature: (t.temperature - 1.5).clamp(20, 200),
        vibration: (t.vibration - 0.5).clamp(0, 100),
        rpm: 0,
        health: (100 - t.stress + 2).clamp(0, 100),
      );
    }

    if (t.failed) return t;

    final wind = (t.windSpeed + (random.nextDouble() * 4 - 2)).clamp(0.0, 120.0);
    final power = wind * cos(t.bladeAngle * pi / 180);
    final stress = t.stress + ((wind / (t.bladeAngle + 1)) * 0.2);
    final failed = stress > 100;
    final temp = (40 + wind * 0.8 + stress * 0.3 + random.nextDouble() * 5).clamp(20.0, 200.0);
    final vib = (stress * 0.6 + wind * 0.15 + random.nextDouble() * 3).clamp(0.0, 100.0);
    final rpmVal = (wind * 12 - stress * 2).clamp(0.0, 1500.0);

    return t.copyWith(
      windSpeed: wind,
      powerOutput: power,
      stress: stress.clamp(0, 120),
      failed: failed,
      health: (100 - stress).clamp(0, 100),
      temperature: temp,
      vibration: vib,
      rpm: rpmVal,
    );
  }
}
