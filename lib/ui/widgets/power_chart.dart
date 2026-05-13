import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/grid_bloc.dart';
import '../../bloc/grid_state.dart';

class PowerChart extends StatelessWidget {
  const PowerChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridBloc, GridBlocState>(
      builder: (context, state) {
        final bloc = context.read<GridBloc>();
        final history = bloc.powerHistory;
        final spots = <FlSpot>[];
        for (int i = 0; i < history.length; i++) {
          spots.add(FlSpot(i.toDouble(), history[i]));
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF161B22),
                const Color(0xFF0D1117),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart, color: Color(0xFF8B949E), size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'POWER TREND',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.grid.totalMW.toStringAsFixed(1)} MW',
                    style: const TextStyle(
                      color: Color(0xFFFFA502),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: spots.length < 2
                    ? Center(
                        child: Text(
                          'Collecting data...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 12,
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 50,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white.withValues(alpha: 0.05),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: const LineTouchData(enabled: false),
                          clipData: const FlClipData.all(),
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: const Color(0xFF00D2FF),
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF00D2FF).withValues(alpha: 0.2),
                                    const Color(0xFF00D2FF).withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 0),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
