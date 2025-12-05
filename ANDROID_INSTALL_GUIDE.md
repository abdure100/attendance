# Installing Android App Directly to Device

This guide explains how to install your Android app directly to a device without going through Google Play Store.

## Prerequisites

1. **Android Device** (phone or tablet)
2. **USB Cable** to connect device to computer
3. **Android Debug Bridge (adb)** - comes with Android Studio or can be installed separately

## Quick Setup

### Step 1: Enable Developer Options on Android Device

1. Go to **Settings** > **About Phone** (or **About Device**)
2. Find **Build Number**
3. Tap **Build Number 7 times**
4. You'll see a message: "You are now a developer!"

### Step 2: Enable USB Debugging

1. Go back to **Settings**
2. Find **Developer Options** (usually under System or Advanced)
3. Enable **USB Debugging**
4. (Optional) Enable **Stay Awake** (keeps screen on while charging)

### Step 3: Connect Device

1. Connect your Android device to your Mac via USB
2. On your device, you'll see a prompt: **"Allow USB debugging?"**
3. Check **"Always allow from this computer"**
4. Tap **"Allow"**

### Step 4: Verify Connection

```bash
# Check if device is detected
adb devices

# Should show something like:
# List of devices attached
# ABC123XYZ    device
```

If you see "unauthorized", tap "Allow" on your device when prompted.

## Installation Methods

### Method 1: Using the Install Script (Easiest)

```bash
./install_android.sh
```

This will:
- Check for connected devices
- Build the app in release mode
- Install directly to your device

### Method 2: Using Flutter Command

```bash
# List available devices
flutter devices

# Install to specific device
flutter install -d <device_id> --release

# Or install to first available device
flutter install --release
```

### Method 3: Build APK and Install Manually

```bash
# Build APK
flutter build apk --release

# Install via adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 4: Using Android Studio

1. Open Android Studio
2. Open your project: `File > Open` > select project folder
3. Connect your device
4. Click the **Run** button (green play icon)
5. Select your device from the device dropdown
6. Click **OK**

## Troubleshooting

### Issue: "No devices found"

**Solutions:**
- Check USB connection
- Enable USB debugging on device
- Accept USB debugging prompt on device
- Try different USB cable
- Try different USB port
- Restart adb: `adb kill-server && adb start-server`

### Issue: "Device unauthorized"

**Solutions:**
- Check device screen for USB debugging prompt
- Tap "Allow" on the prompt
- Check "Always allow from this computer"
- Revoke USB debugging authorizations in Developer Options
- Reconnect device

### Issue: "adb: command not found"

**Solutions:**
- Install Android Studio (includes adb)
- Or install platform tools separately:
  ```bash
  brew install --cask android-platform-tools
  ```
- Add to PATH:
  ```bash
  export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
  ```

### Issue: "Installation failed"

**Solutions:**
- Uninstall existing app first: `adb uninstall com.sphereemr.attendance`
- Check device has enough storage
- Make sure device is unlocked
- Try uninstalling and reinstalling

## Wireless Debugging (Android 11+)

You can also connect wirelessly (no USB cable needed):

1. **On your device:**
   - Go to **Developer Options**
   - Find **Wireless debugging**
   - Enable it
   - Tap **Pair device with pairing code**

2. **On your computer:**
   ```bash
   adb pair <IP_ADDRESS>:<PORT>
   # Enter the pairing code when prompted
   
   adb connect <IP_ADDRESS>:<PORT>
   ```

3. **Verify connection:**
   ```bash
   adb devices
   # Should show your device
   ```

## Useful Commands

```bash
# List all connected devices
adb devices

# List devices with details
adb devices -l

# Get device information
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

# Uninstall app
adb uninstall com.sphereemr.attendance

# Install APK
adb install path/to/app.apk

# Reinstall (uninstall + install)
adb install -r path/to/app.apk

# View device logs
adb logcat

# Clear app data
adb shell pm clear com.sphereemr.attendance

# Restart adb server
adb kill-server
adb start-server
```

## Differences: Direct Install vs Google Play

| Feature | Direct Install | Google Play |
|---------|---------------|-------------|
| **Speed** | Instant | Requires upload/review |
| **Testing** | Perfect for testing | For distribution |
| **Signing** | Debug signing OK | Requires release signing |
| **Updates** | Manual | Automatic |
| **Distribution** | One device at a time | Millions of users |
| **Use Case** | Development/Testing | Production release |

## Best Practices

1. **For Development/Testing**: Use direct install
2. **For Beta Testing**: Use Google Play Internal/Alpha tracks
3. **For Production**: Use Google Play Store
4. **Always test** on real devices before releasing
5. **Use release builds** for final testing (not debug builds)

## Next Steps

After testing with direct install:
1. ✅ Test all features on real device
2. ✅ Verify performance
3. ✅ Check UI on different screen sizes
4. ✅ Build AAB for Google Play: `./build_android.sh`
5. ✅ Upload to Google Play Console

---

**Need help?** Check [Flutter Android Deployment](https://docs.flutter.dev/deployment/android) or [Android Developer Guide](https://developer.android.com/studio/run/device).

