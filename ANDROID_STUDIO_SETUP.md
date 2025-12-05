# Android Studio Setup Guide

This guide explains how to connect Android Studio to your Flutter project for debugging and development.

## Step 1: Open Project in Android Studio

1. **Launch Android Studio**
2. **Open Project:**
   - Click "Open" on the welcome screen, OR
   - File > Open
   - Navigate to: `/Users/abdulali/Desktop/dev/attendance`
   - Click "Open"

3. **Wait for indexing:**
   - Android Studio will index the project
   - This may take a few minutes the first time
   - You'll see "Indexing..." in the status bar

## Step 2: Install Flutter & Dart Plugins

If not already installed:

1. **File > Settings** (or **Android Studio > Preferences** on Mac)
2. **Plugins** (left sidebar)
3. Search for and install:
   - **Flutter** plugin
   - **Dart** plugin (usually installed with Flutter)
4. Click **Apply** and **OK**
5. **Restart Android Studio** when prompted

## Step 3: Configure Flutter SDK

1. **File > Settings** (or **Android Studio > Preferences** on Mac)
2. **Languages & Frameworks > Flutter**
3. **Flutter SDK path:** Should auto-detect, or set to:
   ```
   /Users/abdulali/flutter
   ```
   (or wherever Flutter is installed - check with `which flutter`)
4. Click **Apply** and **OK**

## Step 4: Connect Your Android Device

### Option A: USB Connection (Recommended)

1. **Connect device via USB:**
   - Plug your Android device into your Mac
   - Enable USB Debugging (if not already enabled)

2. **Verify connection:**
   - In Android Studio, look at the top toolbar
   - You should see a device dropdown
   - Your device should appear: `SM X218U` or `R95Y8022DLT`

3. **If device doesn't appear:**
   - Check USB connection
   - Enable USB Debugging on device
   - Accept USB debugging prompt on device
   - Try: **Tools > Device Manager** > Refresh

### Option B: Wireless Debugging (Android 11+)

1. **On your Android device:**
   - Settings > Developer Options
   - Enable "Wireless debugging"
   - Tap "Pair device with pairing code"

2. **In Android Studio:**
   - Tools > Device Manager
   - Click "Pair Device Using Wi-Fi"
   - Enter the pairing code and port
   - Click "Pair"

## Step 5: Run the App

1. **Select your device:**
   - Top toolbar > Device dropdown
   - Select your device (`SM X218U`)

2. **Run the app:**
   - Click the green **Run** button (▶️)
   - Or press `Shift + F10` (Windows/Linux) or `Ctrl + R` (Mac)
   - Or right-click `lib/main.dart` > Run

3. **First run:**
   - Android Studio will build the app
   - This may take a few minutes
   - The app will install and launch on your device

## Step 6: View Logs (Logcat)

1. **Open Logcat:**
   - Bottom panel > **Logcat** tab
   - If not visible: **View > Tool Windows > Logcat**

2. **Filter logs:**
   - Use the filter box at the top
   - Filter by: `flutter` or `attendance`
   - Or filter by package: `com.sphereemr.attendance`

3. **View specific logs:**
   - Click the log level dropdown (Verbose, Debug, Info, Warn, Error)
   - Select "Error" to see only errors

## Step 7: Debug the App

1. **Set breakpoints:**
   - Click in the gutter (left of line numbers) to set a breakpoint
   - Red dot appears when breakpoint is set

2. **Start debugging:**
   - Click the **Debug** button (🐛) instead of Run
   - Or press `Shift + F9` (Windows/Linux) or `Ctrl + D` (Mac)

3. **When breakpoint hits:**
   - Execution pauses
   - You can inspect variables
   - Step through code (F8 to step over, F7 to step into)

## Step 8: Useful Android Studio Features

### Device Manager
- **Tools > Device Manager**
- Create and manage Android emulators
- View connected devices
- Take screenshots

### SDK Manager
- **Tools > SDK Manager**
- Install Android SDK versions
- Install system images for emulators

### Project Structure
- **File > Project Structure**
- Configure app settings
- Manage dependencies

### Terminal
- **View > Tool Windows > Terminal**
- Run Flutter commands directly
- Access to full terminal

## Troubleshooting

### Device Not Showing

**Solution:**
```bash
# Check if device is connected
adb devices

# Restart ADB
adb kill-server
adb start-server

# In Android Studio: Tools > Device Manager > Refresh
```

### Flutter Not Detected

**Solution:**
1. Verify Flutter is installed: `flutter doctor`
2. Set Flutter SDK path in Android Studio settings
3. Restart Android Studio

### Build Errors

**Solution:**
1. **File > Invalidate Caches / Restart**
2. Clean project: **Build > Clean Project**
3. Rebuild: **Build > Rebuild Project**

### Gradle Sync Failed

**Solution:**
1. **File > Sync Project with Gradle Files**
2. Check internet connection (Gradle downloads dependencies)
3. Check `android/gradle.properties` for proxy settings if needed

## Quick Commands in Android Studio

- **Run:** `Shift + F10` (Windows/Linux) or `Ctrl + R` (Mac)
- **Debug:** `Shift + F9` (Windows/Linux) or `Ctrl + D` (Mac)
- **Stop:** `Ctrl + F2`
- **Terminal:** `Alt + F12` (Windows/Linux) or `Option + F12` (Mac)
- **Logcat:** `Alt + 6` (Windows/Linux) or `Cmd + 6` (Mac)

## Your Current Setup

**Project Location:**
```
/Users/abdulali/Desktop/dev/attendance
```

**Connected Device:**
- Device ID: `R95Y8022DLT`
- Model: `SM X218U` (Samsung)
- Android: 15 (API 35)

**To open in Android Studio:**
1. Open Android Studio
2. File > Open
3. Select: `/Users/abdulali/Desktop/dev/attendance`
4. Wait for indexing
5. Select device from dropdown
6. Click Run (▶️)

---

**Need help?** Check [Flutter Android Studio Setup](https://docs.flutter.dev/get-started/editor?tab=androidstudio) or [Android Studio User Guide](https://developer.android.com/studio/intro).

