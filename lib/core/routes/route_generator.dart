import 'package:flutter/material.dart';

import '../../features/home/views/home_screen.dart';
import 'routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(
          settings: settings,
          // Home is open to everyone; signing in is asked for when it's needed (see HomeScreen).
          builder: (_) => const HomeScreen(),
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
