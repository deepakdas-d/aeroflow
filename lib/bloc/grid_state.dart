import '../models/grid_model.dart';

class GridBlocState {
  final GridModel grid;
  final List<String> eventLog;

  GridBlocState(this.grid, {this.eventLog = const []});

  GridBlocState copyWith({
    GridModel? grid,
    List<String>? eventLog,
  }) {
    return GridBlocState(
      grid ?? this.grid,
      eventLog: eventLog ?? this.eventLog,
    );
  }
}
