#!/bin/bash

# Install Android App Directly to Connected Device
# This script builds and installs the app directly to your Android device via USB
# Usage: ./install_android.sh [device_id]

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
echo "  Android Direct Install Script"
echo "=========================================="
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb (Android Debug Bridge) not found"
    echo ""
    echo "💡 To install adb:"
    echo "   1. Install Android Studio, OR"
    echo "   2. Install Android SDK Platform Tools:"
    echo "      brew install --cask android-platform-tools"
    echo ""
    exit 1
fi

# Check if device is connected
echo "📱 Checking for connected Android devices..."
DEVICES=$(adb devices | grep -v "List" | grep "device$" | awk '{print $1}')

if [ -z "$DEVICES" ]; then
    echo "❌ No Android device found!"
    echo ""
    echo "💡 To connect your device:"
    echo "   1. Enable Developer Options on your Android device:"
    echo "      - Go to Settings > About Phone"
    echo "      - Tap 'Build Number' 7 times"
    echo "   2. Enable USB Debugging:"
    echo "      - Go to Settings > Developer Options"
    echo "      - Enable 'USB Debugging'"
    echo "   3. Connect device via USB"
    echo "   4. Accept the USB debugging prompt on your device"
    echo ""
    exit 1
fi

# List available devices
echo "✅ Found device(s):"
adb devices -l | grep -v "List"
echo ""

# Get device ID if provided, otherwise use first device
if [ -n "$1" ]; then
    DEVICE_ID="$1"
    # Verify device exists
    if ! echo "$DEVICES" | grep -q "$DEVICE_ID"; then
        echo "❌ Device '$DEVICE_ID' not found"
        echo "Available devices:"
        echo "$DEVICES"
        exit 1
    fi
else
    # Use first device
    DEVICE_ID=$(echo "$DEVICES" | head -n1)
    if [ $(echo "$DEVICES" | wc -l) -gt 1 ]; then
        echo "⚠️  Multiple devices found. Using first device: $DEVICE_ID"
        echo "   To specify a device: ./install_android.sh <device_id>"
        echo ""
    fi
fi

echo "📱 Target Device: $DEVICE_ID"
echo ""

# Get device info
echo "📋 Device Information:"
DEVICE_MODEL=$(adb -s "$DEVICE_ID" shell getprop ro.product.model 2>/dev/null || echo "Unknown")
DEVICE_ANDROID=$(adb -s "$DEVICE_ID" shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
echo "   Model: $DEVICE_MODEL"
echo "   Android: $DEVICE_ANDROID"
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

# Build and install directly to device
echo "🚀 Building and installing to device..."
echo "   This will build the app and install it directly"
echo ""

flutter install -d "$DEVICE_ID" --release

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✅ App Installed Successfully!"
    echo "=========================================="
    echo ""
    echo "📱 Device: $DEVICE_ID ($DEVICE_MODEL)"
    echo "📦 Package: com.sphereemr.attendance"
    echo ""
    echo "💡 The app should now be installed on your device"
    echo "   Look for 'Attendance' in your app drawer"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "  ❌ Installation Failed"
    echo "=========================================="
    echo ""
    echo "💡 Troubleshooting:"
    echo "   1. Make sure device is unlocked"
    echo "   2. Check USB connection"
    echo "   3. Verify USB debugging is enabled"
    echo "   4. Try: adb devices (should show your device)"
    echo "   5. Try: flutter devices (should list your device)"
    echo ""
    exit 1
fi

