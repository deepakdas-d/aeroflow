import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/grid_bloc.dart';
import '../../bloc/grid_state.dart';

class EventLog extends StatelessWidget {
  const EventLog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridBloc, GridBlocState>(
      builder: (context, state) {
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
                  const Icon(Icons.terminal, color: Color(0xFF8B949E), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'EVENT LOG',
                    style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ED573).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Color(0xFF2ED573),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.eventLog.isEmpty
                    ? Center(
                        child: Text(
                          'No events yet...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.eventLog.length,
                        itemBuilder: (context, index) {
                          final log = state.eventLog[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '›',
                                  style: TextStyle(
                                    color: _getLogColor(log).withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log,
                                    style: TextStyle(
                                      color: _getLogColor(log),
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('CRITICAL') || log.contains('FAILURE')) return const Color(0xFFFF4757);
    if (log.contains('WARNING')) return const Color(0xFFFFA502);
    if (log.contains('maintenance')) return const Color(0xFF00D2FF);
    if (log.contains('online') || log.contains('reset')) return const Color(0xFF2ED573);
    return const Color(0xFF8B949E);
  }
}
