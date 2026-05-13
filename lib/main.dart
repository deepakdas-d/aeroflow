import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/grid_bloc.dart';
import 'engine/simulation_engine.dart';
import 'ui/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aeroflow Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        fontFamily: 'Roboto',
      ),
      home: BlocProvider(
        create: (_) => GridBloc(SimulationEngine()),
        child: const DashboardPage(),
      ),
    );
  }
}
