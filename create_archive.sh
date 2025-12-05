#!/bin/bash

# Create iOS Archive Script
# This script builds and creates an iOS archive for distribution
# Usage: ./create_archive.sh [version] [build_number]

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
echo "  iOS Archive Creation Script"
echo "=========================================="
echo ""

# Get version from pubspec.yaml if not provided
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep "^version:" pubspec.yaml | sed 's/.*+//')

VERSION=${1:-$CURRENT_VERSION}
BUILD_NUMBER=${2:-$((CURRENT_BUILD + 1))}

echo "📱 App Configuration:"
echo "   Bundle ID: com.sphereemr.attendance"
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

# Build iOS app in release mode
echo "🏗️  Building iOS app (Release mode)..."
flutter build ios --release --no-codesign
echo "✅ iOS build complete"
echo ""

# Get the workspace path
WORKSPACE_PATH="ios/Runner.xcworkspace"
SCHEME="Runner"
ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/Runner-$(date +%Y-%m-%d-%H%M%S).xcarchive"

# Create archive directory if it doesn't exist
mkdir -p "$(dirname "$ARCHIVE_PATH")"

echo "📦 Creating archive..."
echo "   Workspace: $WORKSPACE_PATH"
echo "   Scheme: $SCHEME"
echo "   Archive Path: $ARCHIVE_PATH"
echo ""

# Create archive using xcodebuild
xcodebuild archive \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
  echo ""
  echo "=========================================="
  echo "  ✅ Archive Created Successfully!"
  echo "=========================================="
  echo ""
  echo "📦 Archive Location:"
  echo "   $ARCHIVE_PATH"
  echo ""
  echo "📋 Next Steps:"
  echo ""
  echo "1. Open Xcode Organizer:"
  echo "   - Open Xcode"
  echo "   - Go to Window > Organizer (Cmd+Shift+9)"
  echo "   - Click on the Archives tab"
  echo "   - Your archive should appear there"
  echo ""
  echo "2. Distribute to TestFlight:"
  echo "   - Select your archive"
  echo "   - Click 'Distribute App'"
  echo "   - Choose 'App Store Connect'"
  echo "   - Choose 'Upload'"
  echo "   - Follow the prompts to upload"
  echo ""
  echo "3. Or export manually:"
  echo "   xcodebuild -exportArchive \\"
  echo "     -archivePath \"$ARCHIVE_PATH\" \\"
  echo "     -exportOptionsPlist ios/exportOptions.plist \\"
  echo "     -exportPath ./build/export"
  echo ""
else
  echo ""
  echo "=========================================="
  echo "  ❌ Archive Creation Failed"
  echo "=========================================="
  echo ""
  echo "💡 Troubleshooting:"
  echo "   1. Make sure you have Xcode installed"
  echo "   2. Check that the workspace path is correct"
  echo "   3. Try opening Xcode and creating archive manually:"
  echo "      open ios/Runner.xcworkspace"
  echo ""
  exit 1
fi

