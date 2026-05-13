import 'turbine_model.dart';

class GridModel {
  final List<TurbineModel> turbines;
  final double totalMW;
  final double stability;
  final bool gridFailure;

  GridModel({
    required this.turbines,
    required this.totalMW,
    required this.stability,
    required this.gridFailure,
  });

  GridModel copyWith({
    List<TurbineModel>? turbines,
    double? totalMW,
    double? stability,
    bool? gridFailure,
  }) {
    return GridModel(
      turbines: turbines ?? this.turbines,
      totalMW: totalMW ?? this.totalMW,
      stability: stability ?? this.stability,
      gridFailure: gridFailure ?? this.gridFailure,
    );
  }
}
