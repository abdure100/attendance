# Debugging Login Issue

## Current Problem

**Error from Android device:**
```
Failed host lookup: 'fms.sphereemr.com'
SocketException: No address associated with hostname
```

## Root Cause

The Android device cannot resolve or connect to `fms.sphereemr.com`. This is a **network connectivity issue**, not a code issue.

## Solutions

### Solution 1: Check Device Internet Connection

1. **On your Android device:**
   - Open a web browser
   - Try to visit: `https://fms.sphereemr.com`
   - If it doesn't load, the device has network issues

2. **Check WiFi/Mobile Data:**
   - Ensure WiFi is connected OR mobile data is enabled
   - Try switching between WiFi and mobile data
   - Try a different network

### Solution 2: Use Android Studio to Debug

Since you just installed Android Studio:

1. **Open Android Studio**
2. **Open the project:**
   - File > Open > Select your project folder
3. **Connect your device** (or use emulator)
4. **Run the app:**
   - Click the green "Run" button
   - Select your device
5. **View logs:**
   - Bottom panel > "Logcat" tab
   - Filter by: `flutter` or `attendance`
   - You'll see detailed error messages

### Solution 3: Test Network from Device

**Via ADB:**
```bash
# Test DNS resolution
adb -s R95Y8022DLT shell "ping -c 1 fms.sphereemr.com"

# Test connectivity to IP
adb -s R95Y8022DLT shell "ping -c 1 52.72.104.52"
```

### Solution 4: Check App Permissions

The app needs **INTERNET** permission. Check `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Solution 5: Use Android Emulator (Alternative)

If the physical device has network issues:

1. **Open Android Studio**
2. **Tools > Device Manager**
3. **Create Virtual Device** (if needed)
4. **Launch Emulator**
5. **Run app on emulator** (usually has better network)

## Quick Test

**Try this on your Android device:**
1. Open Chrome browser
2. Go to: `https://fms.sphereemr.com/fmi/data/vLatest`
3. If it loads → Network is fine, might be app-specific
4. If it doesn't load → Network/DNS issue on device

## Next Steps

1. **Test network connectivity** on the device
2. **Use Android Studio** to see detailed logs
3. **Try different network** (WiFi vs Mobile Data)
4. **Check if server is accessible** from device browser

---

**The code is correct** - this is a network connectivity issue on the Android device.

