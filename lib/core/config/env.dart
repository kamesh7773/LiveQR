import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, staging, production }

class Env {
  static late Environment _environment;
  static Environment get environment => _environment;

  Env._();

  static Future<void> init(Environment environment) async {
    _environment = environment;
    String fileName;

    switch (environment) {
      case Environment.development:
        fileName = '.env.development';
        break;
      case Environment.staging:
        fileName = '.env.staging';
        break;
      case Environment.production:
        fileName = '.env.production';
        break;
    }

    await dotenv.load(fileName: fileName);
    _logConfiguration(fileName);
  }

  static void _logConfiguration(String fileName) {
    if (kReleaseMode && !enableLogs) return;

    final flavor = _environment.name.toUpperCase();
    final banner =
        '''
╔══════════════════════════════════════════════════════════╗
║  🚀 App launched — flavor: $flavor
╠══════════════════════════════════════════════════════════╣
║  env file        : $fileName
║  API_BASE_URL    : $apiBaseUrl
║  ENABLE_LOGS     : $enableLogs
║  ENABLE_ANALYTICS: $enableAnalytics
║  ENABLE_CRASH    : $enableCrashReporting
╚══════════════════════════════════════════════════════════╝''';

    debugPrint(banner);
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static bool get enableLogs => dotenv.env['ENABLE_LOGS'] == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING'] == 'true';

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
