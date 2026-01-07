# Kiosk Mode Setup Guide (Device Owner)

This guide explains how to set up your Android device as a **dedicated kiosk device** that only runs the Attendance app.

## What This Does

✅ App launches automatically at boot  
✅ No system UI (status bar hidden)  
✅ No navigation bar  
✅ No app switching (Recent Apps disabled)  
✅ Cannot exit without admin PIN  
✅ Device locked to this app only  

---

## ⚠️ IMPORTANT: Factory Reset Required

Setting an app as **Device Owner** can ONLY be done during the **initial device setup** (before any Google account is added). This means:

1. **Factory reset is required** to set up Device Owner
2. **No Google account** should be signed in on the device
3. Once set, the app has full control over the device

---

## Step-by-Step Setup

### Step 1: Build the APK

```bash
cd /Users/abdulali/Desktop/dev/attendance
flutter build apk --release
```

### Step 2: Factory Reset the Device

**On your Samsung Galaxy:**

1. Go to **Settings** → **General management** → **Reset**
2. Tap **Factory data reset**
3. Confirm and wait for reset to complete

**⚠️ This will erase ALL data on the device!**

### Step 3: Initial Device Setup (STOP at WiFi)

After factory reset:

1. Select language
2. Connect to WiFi
3. **STOP HERE** - Do NOT sign in to Google account
4. Skip/decline everything else

### Step 4: Enable Developer Options

1. Go to **Settings** → **About Phone** (or About Device/Tablet)
2. Tap **Build Number** 7 times
3. Developer mode is now enabled

### Step 5: Enable USB Debugging

1. Go to **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Connect device to computer via USB
4. Accept the debugging prompt on device

### Step 6: Verify Connection

```bash
adb devices
# Should show your device
```

### Step 7: Install the App

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 8: Set as Device Owner 🔑

This is the critical step that enables Kiosk Mode:

```bash
adb shell dpm set-device-owner com.sphereemr.attendance/.AttendanceDeviceAdminReceiver
```

You should see:
```
Success: Device owner set to package com.sphereemr.attendance
```

### Step 9: Launch the App

```bash
adb shell am start -n com.sphereemr.attendance/.MainActivity
```

The app will now start in **Kiosk Mode** - fullscreen, no system UI, locked to this app only.

---

## Exiting Kiosk Mode (Admin Only)

From the app, there's a hidden admin exit:
- Use the `KioskService.stopKioskMode("1234")` with the correct PIN
- Default PIN is `1234` (change in `MainActivity.kt`)

Or via ADB:

```bash
# Remove device owner (exits kiosk mode permanently)
adb shell dpm remove-active-admin com.sphereemr.attendance/.AttendanceDeviceAdminReceiver
```

---

## Troubleshooting

### Error: "Not allowed to set device owner"

This means a Google account is already on the device. You must:
1. Factory reset the device
2. Set device owner BEFORE signing into any Google account

### Error: "Device owner already set"

Another app is already device owner. Remove it first:
```bash
adb shell dpm remove-active-admin <current-package>/.DeviceAdminReceiver
```

### Error: "Package not found"

Make sure the app is installed:
```bash
adb shell pm list packages | grep attendance
```

If not listed, install it first:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### App Not Starting on Boot

Make sure the device was rebooted AFTER setting device owner:
```bash
adb reboot
```

---

## Quick Reference Commands

```bash
# Check if device owner is set
adb shell dumpsys device_policy | grep "Device Owner"

# List device admins
adb shell dumpsys device_policy

# Remove device owner
adb shell dpm remove-active-admin com.sphereemr.attendance/.AttendanceDeviceAdminReceiver

# Force stop app
adb shell am force-stop com.sphereemr.attendance

# Uninstall app
adb uninstall com.sphereemr.attendance

# Reboot device
adb reboot

# View app logs
adb logcat -s "MainActivity" "DeviceAdminReceiver" "BootReceiver"
```

---

## Updating the App

To update the app while in Kiosk Mode:

```bash
# Method 1: Direct install (keeps device owner status)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Method 2: If Method 1 fails
adb shell dpm remove-active-admin com.sphereemr.attendance/.AttendanceDeviceAdminReceiver
adb uninstall com.sphereemr.attendance
adb install build/app/outputs/flutter-apk/app-release.apk
adb shell dpm set-device-owner com.sphereemr.attendance/.AttendanceDeviceAdminReceiver
```

---

## Security Considerations

- The admin PIN is hardcoded in `MainActivity.kt` - change it!
- Device Owner has full control over the device
- Consider removing USB debugging after setup for security
- For production, sign the APK with a release key

---

## Files Modified

- `android/app/src/main/AndroidManifest.xml` - Kiosk permissions
- `android/app/src/main/kotlin/.../MainActivity.kt` - Lock Task implementation
- `android/app/src/main/kotlin/.../DeviceAdminReceiver.kt` - Device admin
- `android/app/src/main/kotlin/.../BootReceiver.kt` - Boot on startup
- `android/app/src/main/res/xml/device_admin.xml` - Admin policies
- `lib/services/kiosk_service.dart` - Flutter platform channel

---

## Need Help?

- [Android Enterprise - Device Owner](https://developer.android.com/work/dpc/device-management)
- [Lock Task Mode](https://developer.android.com/work/dpc/dedicated-devices/lock-task-mode)

