import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/grid_bloc.dart';
import '../../bloc/grid_state.dart';

class StabilityGauge extends StatelessWidget {
  const StabilityGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridBloc, GridBlocState>(
      builder: (context, state) {
        final stability = state.grid.stability;
        final gridFailure = state.grid.gridFailure;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF161B22), Color(0xFF0D1117)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gridFailure
                  ? const Color(0xFFFF4757).withValues(alpha: 0.3)
                  : const Color(0xFF30363D),
            ),
            boxShadow: gridFailure
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF4757).withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: _getColor(stability),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'GRID STABILITY',
                    style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Gauge — smaller fixed size to always fit
              Center(
                child: SizedBox(
                  width: 130,
                  height: 75,
                  child: CustomPaint(
                    painter: _GaugePainter(
                      value: stability / 100,
                      color: _getColor(stability),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stability.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _getColor(stability),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          Text(
                            _getLabel(stability),
                            style: TextStyle(
                              color: _getColor(
                                stability,
                              ).withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    label: 'Total MW',
                    value: state.grid.totalMW.toStringAsFixed(1),
                    color: const Color(0xFFFFA502),
                  ),
                  _MiniStat(
                    label: 'Active',
                    value:
                        '${state.grid.turbines.where((t) => !t.failed && !t.maintenanceMode).length}/${state.grid.turbines.length}',
                    color: const Color(0xFF2ED573),
                  ),
                  _MiniStat(
                    label: 'Avg Stress',
                    value:
                        '${(state.grid.turbines.fold(0.0, (s, t) => s + t.stress) / state.grid.turbines.length).toStringAsFixed(0)}%',
                    color: const Color(0xFFFF6B81),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(double stability) {
    if (stability > 70) return const Color(0xFF2ED573);
    if (stability > 40) return const Color(0xFFFFA502);
    return const Color(0xFFFF4757);
  }

  String _getLabel(double stability) {
    if (stability > 70) return 'NOMINAL';
    if (stability > 40) return 'WARNING';
    return 'CRITICAL';
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = const Color(0xFF21262D)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    final valuePaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: pi,
        endAngle: 2 * pi,
        colors: [color.withValues(alpha: 0.4), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * value,
      false,
      valuePaint,
    );

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * value,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
