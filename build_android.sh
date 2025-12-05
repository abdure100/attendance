#!/bin/bash

# Build Android App Bundle for Google Play Store
# This script builds an Android App Bundle (AAB) for distribution via Google Play Store
# Usage: ./build_android.sh [version] [build_number]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo ""
echo "=========================================="
echo "  Android App Bundle Build Script"
echo "=========================================="
echo ""

# Get version from pubspec.yaml if not provided
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep "^version:" pubspec.yaml | sed 's/.*+//')

VERSION=${1:-$CURRENT_VERSION}
BUILD_NUMBER=${2:-$((CURRENT_BUILD + 1))}

echo "📱 App Configuration:"
echo "   Package Name: com.sphereemr.attendance"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"
echo ""

# Update pubspec.yaml version
echo "📝 Updating version in pubspec.yaml..."
sed -i '' "s/^version:.*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
echo "✅ Version updated to $VERSION+$BUILD_NUMBER"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo "✅ Clean complete"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Generate code
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs || true
echo "✅ Code generation complete"
echo ""

# Build Android App Bundle (AAB) for Google Play Store
echo "🏗️  Building Android App Bundle (AAB)..."
echo "   This is the format required by Google Play Store"
echo ""

flutter build appbundle --release

if [ $? -eq 0 ]; then
  AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
  
  echo ""
  echo "=========================================="
  echo "  ✅ Android App Bundle Created!"
  echo "=========================================="
  echo ""
  echo "📦 AAB Location:"
  echo "   $AAB_PATH"
  echo ""
  
  # Get file size
  if [ -f "$AAB_PATH" ]; then
    FILE_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    echo "   File Size: $FILE_SIZE"
    echo ""
  fi
  
  echo "📋 Next Steps for Google Play Store:"
  echo ""
  echo "1. ⚠️  IMPORTANT: Sign your app (if not already signed)"
  echo "   - Google Play requires apps to be signed"
  echo "   - You can use Google Play App Signing (recommended)"
  echo "   - Or sign manually with a keystore"
  echo ""
  echo "2. Create/Update App in Google Play Console:"
  echo "   - Go to https://play.google.com/console"
  echo "   - Create a new app or select existing app"
  echo "   - Package name must match: com.sphereemr.attendance"
  echo ""
  echo "3. Upload the AAB:"
  echo "   - Go to Production (or Internal/Alpha/Beta testing)"
  echo "   - Click 'Create new release'"
  echo "   - Upload: $AAB_PATH"
  echo "   - Fill in release notes"
  echo "   - Review and roll out"
  echo ""
  echo "4. Testing Options:"
  echo "   - Internal testing: Fastest, up to 100 testers"
  echo "   - Closed testing (Alpha/Beta): More testers"
  echo "   - Open testing: Public beta"
  echo "   - Production: Public release"
  echo ""
  echo "📝 Additional Notes:"
  echo "   - AAB format is required for new apps (APK is deprecated)"
  echo "   - Google Play will optimize the AAB for different devices"
  echo "   - First upload may take longer for processing"
  echo ""
  
  # Check if keystore exists
  KEYSTORE_PATH="android/app/upload-keystore.jks"
  if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Signing Configuration:"
    echo "   No keystore found at: $KEYSTORE_PATH"
    echo "   Google Play App Signing is recommended for new apps"
    echo "   You can upload an unsigned AAB and let Google sign it"
    echo ""
  fi
  
else
  echo ""
  echo "=========================================="
  echo "  ❌ Build Failed"
  echo "=========================================="
  echo ""
  echo "💡 Troubleshooting:"
  echo "   1. Make sure Android SDK is installed"
  echo "   2. Run: flutter doctor"
  echo "   3. Check Android Studio is set up correctly"
  echo "   4. Verify ANDROID_HOME environment variable"
  echo ""
  exit 1
fi

