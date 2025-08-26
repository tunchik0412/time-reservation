#!/bin/bash

# Google OAuth Setup Helper Script
# This script helps you get the SHA-1 fingerprint for Android Google Sign-In

echo "🔧 Google OAuth Setup Helper"
echo "================================="
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool not found. Please install Java JDK."
    exit 1
fi

echo "📱 Getting Android SHA-1 fingerprint for Google OAuth..."
echo ""

# Debug keystore path
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "🔍 Found debug keystore at: $DEBUG_KEYSTORE"
    echo ""
    echo "SHA-1 fingerprint for DEVELOPMENT (copy this to Google Cloud Console):"
    echo "======================================================================="
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android | grep SHA1
    echo ""
    echo "📋 Copy the SHA1 value above and paste it in Google Cloud Console"
    echo "   → APIs & Services → Credentials → Android OAuth Client"
else
    echo "❌ Debug keystore not found at $DEBUG_KEYSTORE"
    echo "   Make sure you have Android SDK installed and have built your app at least once"
fi

echo ""
echo "🔗 Useful Links:"
echo "   Google Cloud Console: https://console.cloud.google.com/"
echo "   Android Setup Guide: https://developers.google.com/identity/sign-in/android/start"
echo ""
echo "📝 Next Steps:"
echo "   1. Create OAuth Client ID in Google Cloud Console"
echo "   2. Add the SHA1 fingerprint above"
echo "   3. Set package name to: com.example.time_reservation"
echo "   4. Copy the Client ID to your Flutter app configuration"
