# AeroFlow Grid Command Center

AeroFlow Grid Command Center is a real-time wind farm simulation dashboard built with Flutter. It provides a comprehensive interface for monitoring and managing a simulated wind turbine grid, featuring real-time data visualization, stability monitoring, and event logging.

## Features

- **Real-time Simulation**: Simulates wind turbine performance with dynamic wind speeds, blade angles, and power output calculations.
- **Interactive Dashboard**: Responsive UI with adaptive layouts for desktop, tablet, and mobile devices.
- **State Management**: Uses BLoC pattern for efficient state management and event handling.
- **Data Visualization**: Charts and gauges for power output, stability metrics, and turbine health.
- **Event Logging**: Real-time event log for system alerts, failures, and maintenance notifications.
- **Cascading Failure Simulation**: Models how turbine failures can affect neighboring units.
- **Multi-Platform Support**: Runs on Android, iOS, Web, Windows, Linux, and macOS.

## Screenshots

_(Add screenshots here if available)_

## Getting Started

### Prerequisites

- Flutter SDK (^3.10.4)
- Dart SDK (^3.10.4)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd aeroflow
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Different Platforms

- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`
- **Windows**: `flutter build windows`
- **Linux**: `flutter build linux`
- **macOS**: `flutter build macos`

## Project Structure

- `lib/main.dart`: Application entry point and theme configuration.
- `lib/bloc/`: BLoC pattern implementation for state management.
- `lib/engine/`: Simulation engine for wind turbine grid calculations.
- `lib/models/`: Data models for turbines and grid state.
- `lib/ui/`: User interface components and dashboard layout.

## Dependencies

- `flutter_bloc`: State management
- `equatable`: Value equality for models
- `fl_chart`: Data visualization charts
- `google_fonts`: Custom typography
- `flutter_launcher_icons`: App icons generation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
