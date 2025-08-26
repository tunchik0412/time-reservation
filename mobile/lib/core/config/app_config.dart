import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration service to manage environment variables
class AppConfig {
  static late String _environment;
  
  /// Initialize the configuration with the specified environment
  static Future<void> initialize({String? environment}) async {
    // Check for dart-define environment first, then fallback to parameter or default
    final envFromDefine = const String.fromEnvironment('ENVIRONMENT');
    _environment = envFromDefine.isNotEmpty 
        ? envFromDefine 
        : environment ?? 'development';
    
    // Load the appropriate .env file based on environment
    String envFile = '.env.$_environment';
    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // Fallback to default .env file if environment-specific file doesn't exist
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // If no .env files exist, continue with empty environment
        print('Warning: No .env files found, using default values');
      }
    }
  }
  
  /// Get the API base URL
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  }
  
  /// Get the current environment
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? _environment;
  }
  
  /// Get the app name
  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'Time Reservation';
  }
  
  /// Check if debug mode is enabled
  static bool get isDebugMode {
    return dotenv.env['DEBUG']?.toLowerCase() == 'true';
  }
  
  /// Check if running in development environment
  static bool get isDevelopment {
    return environment == 'development';
  }
  
  /// Check if running in production environment
  static bool get isProduction {
    return environment == 'production';
  }
  
  /// Get all available configuration values (for debugging)
  static Map<String, String> get allConfig {
    return Map<String, String>.from(dotenv.env);
  }
  
  /// Print configuration summary (for debugging)
  static void printConfig() {
    if (isDebugMode) {
      print('=== App Configuration ===');
      print('Environment: $environment');
      print('API Base URL: $apiBaseUrl');
      print('App Name: $appName');
      print('Debug Mode: $isDebugMode');
      print('========================');
    }
  }
}
