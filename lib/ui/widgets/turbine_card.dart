import 'package:aeroflow/ui/interaction_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/grid_bloc.dart';
import '../../bloc/grid_event.dart';
import '../../bloc/grid_state.dart';
import '../../models/turbine_model.dart';
import 'blade_dial.dart';

class TurbineCard extends StatefulWidget {
  final int index;
  const TurbineCard({super.key, required this.index});

  @override
  State<TurbineCard> createState() => _TurbineCardState();
}

class _TurbineCardState extends State<TurbineCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocSelector<GridBloc, GridBlocState, TurbineModel>(
        selector: (state) => state.grid.turbines[widget.index],
        builder: (context, turbine) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: turbine.failed
                    ? [const Color(0xFF2D0A0A), const Color(0xFF1A0505)]
                    : turbine.shutdown
                    ? [const Color(0xFF1A1A1A), const Color(0xFF111111)]
                    : turbine.maintenanceMode
                    ? [const Color(0xFF0A1A2D), const Color(0xFF05101A)]
                    : [const Color(0xFF161B22), const Color(0xFF0D1117)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _borderColor(turbine),
                width: turbine.failed ? 1.5 : 1,
              ),
              boxShadow: turbine.failed
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF4757).withValues(alpha: 0.12),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Collapsed tile (always visible) ──────────────────────
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Row(
                          children: [
                            Icon(
                              turbine.failed
                                  ? Icons.error_outline
                                  : turbine.shutdown
                                  ? Icons.power_settings_new
                                  : Icons.wind_power,
                              color: _statusColor(turbine),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'T-${turbine.id}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  turbine,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                turbine.statusLabel,
                                style: TextStyle(
                                  color: _statusColor(turbine),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Power output
                            Row(
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Color(0xFFFFA502),
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${turbine.powerOutput.toStringAsFixed(1)} MW',
                                  style: const TextStyle(
                                    color: Color(0xFFFFA502),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              turns: _expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 280),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white.withValues(alpha: 0.4),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Health bar
                        _bar(
                          'Health',
                          turbine.health,
                          _healthColor(turbine.health),
                        ),
                        const SizedBox(height: 5),
                        // Stress bar
                        _bar(
                          'Stress',
                          turbine.stress,
                          _stressColor(turbine.stress),
                        ),
                        const SizedBox(height: 6),
                        // Sensors row
                        _buildSensors(turbine),
                      ],
                    ),
                  ),
                ),

                // ── Expanded controls (animated) ──────────────────────────
                SizeTransition(
                  sizeFactor: _expandAnim,
                  child: Column(
                    children: [
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          children: [
                            _buildControls(context, turbine),
                            const SizedBox(height: 14),
                            _buildActions(context, turbine),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Controls: Wind slider + Blade dial ─────────────────────────────────
  Widget _buildControls(BuildContext context, TurbineModel t) {
    final disabled = t.failed || t.shutdown;

    return Column(
      children: [
        // Wind Speed
        Row(
          children: [
            const Icon(Icons.air, color: Color(0xFF00D2FF), size: 14),
            const SizedBox(width: 6),
            Text(
              'Wind Speed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Text(
              '${t.windSpeed.toStringAsFixed(0)} m/s',
              style: const TextStyle(
                color: Color(0xFF00D2FF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: const Color(0xFF00D2FF),
            inactiveTrackColor: const Color(0xFF00D2FF).withValues(alpha: 0.12),
            thumbColor: const Color(0xFF00D2FF),
            overlayColor: const Color(0xFF00D2FF).withValues(alpha: 0.15),
            disabledActiveTrackColor: const Color(
              0xFF00D2FF,
            ).withValues(alpha: 0.2),
            disabledInactiveTrackColor: const Color(
              0xFF00D2FF,
            ).withValues(alpha: 0.05),
            disabledThumbColor: const Color(0xFF00D2FF).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: t.windSpeed.clamp(0, 120),

            max: 120,

            onChangeStart: (_) {
              isInteractingNotifier.value = true;
            },

            onChangeEnd: (_) {
              isInteractingNotifier.value = false;
            },

            onChanged: disabled
                ? null
                : (v) {
                    context.read<GridBloc>().add(UpdateWindSpeed(t.id, v));
                  },
          ),
        ),
        const SizedBox(height: 16),

        // Blade Angle dial — much larger
        Row(
          children: [
            const Icon(Icons.rotate_right, color: Color(0xFF7A5FFF), size: 14),
            const SizedBox(width: 6),
            Text(
              'Blade Angle',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Text(
              '${t.bladeAngle.toStringAsFixed(0)}°',
              style: const TextStyle(
                color: Color(0xFF7A5FFF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: BladeDial(
              value: t.bladeAngle,
              max: 90,
              onChanged: disabled
                  ? null
                  : (v) =>
                        context.read<GridBloc>().add(UpdateBladeAngle(t.id, v)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, TurbineModel t) {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: t.maintenanceMode ? 'EXIT MAINT' : 'MAINTENANCE',
            icon: Icons.build_outlined,
            color: const Color(0xFF00D2FF),
            active: t.maintenanceMode,
            onTap: t.failed
                ? null
                : () => context.read<GridBloc>().add(ToggleMaintenance(t.id)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionBtn(
            label: t.shutdown ? 'START' : 'STOP',
            icon: Icons.power_settings_new,
            color: const Color(0xFFFFA502),
            active: t.shutdown,
            onTap: t.failed
                ? null
                : () => context.read<GridBloc>().add(ShutdownTurbine(t.id)),
          ),
        ),
        if (t.failed) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              label: 'RESET',
              icon: Icons.refresh,
              color: const Color(0xFF2ED573),
              active: false,
              onTap: () => context.read<GridBloc>().add(ResetTurbine(t.id)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 34,
          child: Text(
            '${value.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensors(TurbineModel t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sensor(
          'TEMP',
          '${t.temperature.toStringAsFixed(0)}°C',
          t.temperature > 120
              ? const Color(0xFFFF4757)
              : const Color(0xFF8B949E),
        ),
        _sensor(
          'VIB',
          t.vibration.toStringAsFixed(0),
          t.vibration > 60 ? const Color(0xFFFFA502) : const Color(0xFF8B949E),
        ),
        _sensor('RPM', t.rpm.toStringAsFixed(0), const Color(0xFF8B949E)),
        _sensor(
          'WIND',
          '${t.windSpeed.toStringAsFixed(0)} m/s',
          const Color(0xFF00D2FF),
        ),
      ],
    );
  }

  Widget _sensor(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required bool active,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? Colors.white24
                  : (active ? color : Colors.white54),
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: onTap == null
                    ? Colors.white24
                    : (active ? color : Colors.white54),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(TurbineModel t) {
    if (t.failed) return const Color(0xFFFF4757).withValues(alpha: 0.5);
    if (t.shutdown) return Colors.white.withValues(alpha: 0.1);
    if (t.maintenanceMode) {
      return const Color(0xFF00D2FF).withValues(alpha: 0.3);
    }
    if (t.stress > 80) return const Color(0xFFFFA502).withValues(alpha: 0.3);
    return const Color(0xFF30363D);
  }

  Color _statusColor(TurbineModel t) {
    if (t.failed) return const Color(0xFFFF4757);
    if (t.shutdown) return Colors.white38;
    if (t.maintenanceMode) return const Color(0xFF00D2FF);
    if (t.stress > 80) return const Color(0xFFFF4757);
    if (t.stress > 50) return const Color(0xFFFFA502);
    return const Color(0xFF2ED573);
  }

  Color _stressColor(double s) {
    if (s > 80) return const Color(0xFFFF4757);
    if (s > 50) return const Color(0xFFFFA502);
    return const Color(0xFF2ED573);
  }

  Color _healthColor(double h) {
    if (h > 70) return const Color(0xFF2ED573);
    if (h > 40) return const Color(0xFFFFA502);
    return const Color(0xFFFF4757);
  }
}
