import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/grid_bloc.dart';
import '../../bloc/grid_event.dart';
import '../../bloc/grid_state.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridBloc, GridBlocState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _CompactTopBar(state: state);
            }
            return _FullTopBar(state: state);
          },
        );
      },
    );
  }
}

// ── Full top bar ≥600px ────────────────────────────────────────────────────
class _FullTopBar extends StatelessWidget {
  final GridBlocState state;
  const _FullTopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final grid = state.grid;
    final active = grid.turbines
        .where((t) => !t.failed && !t.maintenanceMode && !t.shutdown)
        .length;
    final failed = grid.turbines.where((t) => t.failed).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(
          bottom: BorderSide(
            color: grid.gridFailure
                ? const Color(0xFFFF4757).withValues(alpha: 0.5)
                : const Color(0xFF21262D),
          ),
        ),
      ),
      child: Row(
        children: [
          _Logo(gridFailure: grid.gridFailure),
          const SizedBox(width: 10),
          _BrandText(),
          const SizedBox(width: 24),
          _PresetBtn(
            label: 'CALM',
            preset: EnvironmentPreset.calmDay,
            color: const Color(0xFF2ED573),
          ),
          const SizedBox(width: 6),
          _PresetBtn(
            label: 'STORM',
            preset: EnvironmentPreset.stormWarning,
            color: const Color(0xFFFFA502),
          ),
          const SizedBox(width: 6),
          _PresetBtn(
            label: 'PEAK',
            preset: EnvironmentPreset.gridPeak,
            color: const Color(0xFFFF4757),
          ),
          const Spacer(),
          _Chip(
            icon: Icons.bolt,
            text: '${grid.totalMW.toStringAsFixed(1)} MW',
            color: const Color(0xFFFFA502),
          ),
          const SizedBox(width: 10),
          _Chip(
            icon: Icons.speed,
            text: '${grid.stability.toStringAsFixed(0)}%',
            color: _stabColor(grid.stability),
          ),
          const SizedBox(width: 10),
          _Chip(
            icon: Icons.wind_power,
            text: '$active ON',
            color: const Color(0xFF2ED573),
          ),
          if (failed > 0) ...[
            const SizedBox(width: 10),
            _Chip(
              icon: Icons.warning_amber,
              text: '$failed FAIL',
              color: const Color(0xFFFF4757),
            ),
          ],
          const SizedBox(width: 12),
          _StatusBadge(gridFailure: grid.gridFailure),
        ],
      ),
    );
  }
}

// ── Compact top bar <600px ─────────────────────────────────────────────────
// Fixed: proper touch targets, readable font sizes, no overflow
class _CompactTopBar extends StatelessWidget {
  final GridBlocState state;
  const _CompactTopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final grid = state.grid;
    final active = grid.turbines
        .where((t) => !t.failed && !t.maintenanceMode && !t.shutdown)
        .length;
    final failed = grid.turbines.where((t) => t.failed).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(
          bottom: BorderSide(
            color: grid.gridFailure
                ? const Color(0xFFFF4757).withValues(alpha: 0.5)
                : const Color(0xFF21262D),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row 1: Logo + brand + status badge ──────────────────────
              Row(
                children: [
                  _Logo(gridFailure: grid.gridFailure),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'AEROFLOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'WIND GRID CONTROL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _StatusBadge(gridFailure: grid.gridFailure),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 2: Stats chips ───────────────────────────────────────
              Row(
                children: [
                  _Chip(
                    icon: Icons.bolt,
                    text: '${grid.totalMW.toStringAsFixed(1)} MW',
                    color: const Color(0xFFFFA502),
                    fontSize: 13,
                  ),
                  const SizedBox(width: 12),
                  _Chip(
                    icon: Icons.speed,
                    text: '${grid.stability.toStringAsFixed(0)}% stable',
                    color: _stabColor(grid.stability),
                    fontSize: 13,
                  ),
                  const SizedBox(width: 12),
                  _Chip(
                    icon: Icons.wind_power,
                    text: '$active ON',
                    color: const Color(0xFF2ED573),
                    fontSize: 13,
                  ),
                  if (failed > 0) ...[
                    const SizedBox(width: 12),
                    _Chip(
                      icon: Icons.warning_amber,
                      text: '$failed FAIL',
                      color: const Color(0xFFFF4757),
                      fontSize: 13,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 3: Preset buttons ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _PresetBtn(
                      label: 'CALM',
                      preset: EnvironmentPreset.calmDay,
                      color: const Color(0xFF2ED573),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PresetBtn(
                      label: 'STORM',
                      preset: EnvironmentPreset.stormWarning,
                      color: const Color(0xFFFFA502),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PresetBtn(
                      label: 'PEAK',
                      preset: EnvironmentPreset.gridPeak,
                      color: const Color(0xFFFF4757),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final bool gridFailure;
  const _Logo({required this.gridFailure});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gridFailure
              ? [const Color(0xFFFF4757), const Color(0xFFFF6B81)]
              : [const Color(0xFF00D2FF), const Color(0xFF7A5FFF)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.air, color: Colors.white, size: 22),
    );
  }
}

class _BrandText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AEROFLOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        Text(
          'WIND GRID CONTROL',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 8,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool gridFailure;
  const _StatusBadge({required this.gridFailure});

  @override
  Widget build(BuildContext context) {
    final color = gridFailure
        ? const Color(0xFFFF4757)
        : const Color(0xFF2ED573);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            gridFailure ? 'FAILURE' : 'ONLINE',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetBtn extends StatelessWidget {
  final String label;
  final EnvironmentPreset preset;
  final Color color;
  const _PresetBtn({
    required this.label,
    required this.preset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<GridBloc>().add(ApplyPreset(preset)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final double fontSize;
  const _Chip({
    required this.icon,
    required this.text,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: fontSize + 2),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Color _stabColor(double s) {
  if (s > 70) return const Color(0xFF2ED573);
  if (s > 40) return const Color(0xFFFFA502);
  return const Color(0xFFFF4757);
}
