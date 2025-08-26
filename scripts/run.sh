#!/bin/bash

# Development helper script for running Flutter app with different environments
# Usage: ./scripts/run.sh [development|production]

set -e

ENVIRONMENT=${1:-development}

echo "🚀 Running Flutter app in $ENVIRONMENT mode"

# Change to the mobile directory
cd "$(dirname "$0")/../mobile"

# Set environment and run
case $ENVIRONMENT in
  "development")
    echo "📱 Starting development mode with hot reload..."
    flutter run --dart-define=ENVIRONMENT=development
    ;;
  "production")
    echo "🌍 Starting production mode..."
    flutter run --release --dart-define=ENVIRONMENT=production
    ;;
  *)
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Valid options: development, production"
    exit 1
    ;;
esac
