#!/bin/bash

# Build script for Flutter app with environment support
# Usage: ./scripts/build.sh [development|production] [platform]

set -e

# Default values
ENVIRONMENT=${1:-development}
PLATFORM=${2:-android}

echo "🚀 Building Flutter app for $ENVIRONMENT environment on $PLATFORM platform"

# Set environment variables based on the target environment
case $ENVIRONMENT in
  "development")
    echo "📱 Using development configuration"
    export FLUTTER_ENVIRONMENT=development
    ;;
  "production")
    echo "🌍 Using production configuration"
    export FLUTTER_ENVIRONMENT=production
    ;;
  *)
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Valid options: development, production"
    exit 1
    ;;
esac

# Change to the mobile directory
cd "$(dirname "$0")/../mobile"

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build the app based on platform
case $PLATFORM in
  "android")
    echo "🤖 Building Android APK..."
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build apk --release --dart-define=ENVIRONMENT=production
    else
      flutter build apk --debug --dart-define=ENVIRONMENT=development
    fi
    ;;
  "ios")
    echo "🍎 Building iOS app..."
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build ios --release --dart-define=ENVIRONMENT=production
    else
      flutter build ios --debug --dart-define=ENVIRONMENT=development
    fi
    ;;
  "web")
    echo "🌐 Building Web app..."
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build web --release --dart-define=ENVIRONMENT=production
    else
      flutter build web --dart-define=ENVIRONMENT=development
    fi
    ;;
  *)
    echo "❌ Invalid platform: $PLATFORM"
    echo "Valid options: android, ios, web"
    exit 1
    ;;
esac

echo "✅ Build completed successfully!"
echo "📍 Environment: $ENVIRONMENT"
echo "📱 Platform: $PLATFORM"
