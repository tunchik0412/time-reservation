# Environment Configuration Guide

## Overview

The Flutter app now supports environment-based configuration using `.env` files and the `flutter_dotenv` package. This allows you to easily switch between development, staging, and production environments.

## 📁 Environment Files

### `.env` (Default)
```env
API_BASE_URL=http://localhost:3000
ENVIRONMENT=development
APP_NAME=Time Reservation
DEBUG=true
```

### `.env.development`
```env
API_BASE_URL=http://localhost:3000
ENVIRONMENT=development
APP_NAME=Time Reservation (Dev)
DEBUG=true
```

### `.env.production`
```env
API_BASE_URL=https://your-production-api.com
ENVIRONMENT=production
APP_NAME=Time Reservation
DEBUG=false
```

## 🔧 Configuration Usage

### In Code
```dart
import 'package:your_app/core/config/app_config.dart';

// Initialize configuration (usually in main.dart)
await AppConfig.initialize(environment: 'development');

// Use configuration values
String apiUrl = AppConfig.apiBaseUrl;
bool isDebug = AppConfig.isDebugMode;
String appName = AppConfig.appName;

// Environment checks
if (AppConfig.isDevelopment) {
  print('Running in development mode');
}

if (AppConfig.isProduction) {
  // Production-specific logic
}
```

### API Service Integration
The `ApiService` automatically uses the configured base URL:

```dart
// ApiService now dynamically gets the base URL from configuration
static String get baseUrl => AppConfig.apiBaseUrl;
```

## 🚀 Running with Different Environments

### Method 1: Using Helper Scripts

**Development Mode:**
```bash
./scripts/run.sh development
```

**Production Mode:**
```bash
./scripts/run.sh production
```

### Method 2: Direct Flutter Commands

**Development:**
```bash
flutter run --dart-define=ENVIRONMENT=development
```

**Production:**
```bash
flutter run --release --dart-define=ENVIRONMENT=production
```

### Method 3: Default Environment
```bash
# Uses development environment by default
flutter run
```

## 🏗️ Building for Different Environments

### Using Build Script
```bash
# Build Android APK for production
./scripts/build.sh production android

# Build iOS app for development
./scripts/build.sh development ios

# Build web app for production
./scripts/build.sh production web
```

### Direct Build Commands
```bash
# Production build
flutter build apk --release --dart-define=ENVIRONMENT=production

# Development build
flutter build apk --debug --dart-define=ENVIRONMENT=development
```

## 🔍 Configuration Options

| Variable | Description | Development | Production |
|----------|-------------|-------------|------------|
| `API_BASE_URL` | Backend API endpoint | `http://localhost:3000` | Your production URL |
| `ENVIRONMENT` | Current environment | `development` | `production` |
| `APP_NAME` | Application display name | `Time Reservation (Dev)` | `Time Reservation` |
| `DEBUG` | Debug mode flag | `true` | `false` |

## 🛠️ Adding New Configuration Variables

1. **Add to `.env` files:**
```env
NEW_CONFIG_KEY=value
```

2. **Add getter to `AppConfig`:**
```dart
static String get newConfigKey {
  return dotenv.env['NEW_CONFIG_KEY'] ?? 'default_value';
}
```

3. **Use in your code:**
```dart
String value = AppConfig.newConfigKey;
```

## 🔐 Security Best Practices

### ✅ DO:
- Keep sensitive production values in `.env.production`
- Use different API keys for different environments
- Add `.env.local` to `.gitignore` for local overrides
- Validate required environment variables on app startup

### ❌ DON'T:
- Commit sensitive production secrets to version control
- Use production credentials in development
- Hard-code environment-specific values in source code

## 🌍 Environment-Specific Features

### Development Environment
- Debug logging enabled
- Local API endpoints
- Hot reload enabled
- Development-specific UI indicators

### Production Environment
- Optimized performance
- Production API endpoints
- Error reporting enabled
- Analytics enabled

## 🧪 Testing Environment Configuration

```dart
void main() {
  group('AppConfig Tests', () {
    setUpAll(() async {
      await AppConfig.initialize(environment: 'development');
    });

    test('should load development configuration', () {
      expect(AppConfig.environment, equals('development'));
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isProduction, isFalse);
    });

    test('should return correct API base URL', () {
      expect(AppConfig.apiBaseUrl, equals('http://localhost:3000'));
    });
  });
}
```

## 🔄 Environment Switching Workflow

1. **Development:**
   - Use `./scripts/run.sh development`
   - Points to local backend at `localhost:3000`
   - Debug mode enabled

2. **Staging/Testing:**
   - Create `.env.staging` with staging API URL
   - Build with staging environment
   - Test with production-like data

3. **Production:**
   - Use `./scripts/build.sh production`
   - Points to production API
   - All debugging disabled

## 📱 Platform-Specific Configuration

You can also add platform-specific configurations:

```dart
static String get platformSpecificValue {
  if (Platform.isIOS) {
    return dotenv.env['IOS_SPECIFIC_VALUE'] ?? 'ios_default';
  } else if (Platform.isAndroid) {
    return dotenv.env['ANDROID_SPECIFIC_VALUE'] ?? 'android_default';
  }
  return dotenv.env['DEFAULT_VALUE'] ?? 'default';
}
```

## 🚨 Troubleshooting

### Configuration Not Loading
- Check if `.env` files exist in the correct location
- Verify file names match exactly (`.env.development`, not `.env.dev`)
- Ensure files are included in `pubspec.yaml` assets

### Wrong Environment Values
- Check `--dart-define=ENVIRONMENT=xxx` parameter
- Verify environment name matches file suffix
- Use `AppConfig.printConfig()` for debugging

### Build Issues
- Clean build cache: `flutter clean && flutter pub get`
- Verify environment file syntax (no spaces around `=`)
- Check file permissions on environment files

This configuration system provides a robust foundation for managing different environments in your Flutter application! 🎉
