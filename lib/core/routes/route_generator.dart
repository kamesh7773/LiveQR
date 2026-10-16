import 'package:flutter/material.dart';

import '../../features/auth/views/auth_gate.dart';
import 'routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
