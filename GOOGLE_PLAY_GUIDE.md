# Google Play Store Distribution Guide

This guide explains how to build and distribute your Android app via Google Play Store.

## Prerequisites

1. **Google Play Developer Account**
   - Sign up at https://play.google.com/console
   - One-time registration fee: $25 USD
   - Package name: `com.sphereemr.attendance`

2. **Android Development Setup**
   - Android SDK installed
   - Flutter configured for Android
   - Run `flutter doctor` to verify setup

## Quick Start: Build Android App Bundle

The easiest way to prepare for Google Play Store:

```bash
./build_android.sh
```

Or specify version and build number:
```bash
./build_android.sh 1.0.0 1
```

This will create an Android App Bundle (AAB) at:
```
build/app/outputs/bundle/release/app-release.aab
```

## App Signing

### Option 1: Google Play App Signing (Recommended)

**For new apps**, Google Play can manage signing for you:

1. Upload your **unsigned** AAB to Google Play Console
2. Google Play will generate a signing key
3. All future releases will be automatically signed
4. You don't need to manage keystores yourself

**Advantages:**
- No keystore management
- Automatic key security
- Can recover from lost keys
- Easier for teams

### Option 2: Manual Signing

If you prefer to sign manually:

1. **Create a keystore:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Create key.properties file:**
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Configure signing in `android/app/build.gradle.kts`:**
   ```kotlin
   signingConfigs {
       create("release") {
           val keystorePropertiesFile = rootProject.file("key.properties")
           val keystoreProperties = Properties()
           keystoreProperties.load(FileInputStream(keystorePropertiesFile))
           
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   
   buildTypes {
       getByName("release") {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

## Step-by-Step: Upload to Google Play Store

### Step 1: Create App in Google Play Console

1. Go to https://play.google.com/console
2. Click **"Create app"**
3. Fill in:
   - **App name**: Attendance (or your preferred name)
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free (or Paid)
   - **Declarations**: Accept terms
4. Click **"Create app"**

### Step 2: Complete Store Listing

1. Go to **Store presence > Main store listing**
2. Fill in required information:
   - App name
   - Short description (80 characters)
   - Full description (4000 characters)
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (at least 2, up to 8)
   - Category
   - Contact details
3. Click **"Save"**

### Step 3: Set Up App Content

1. Go to **Policy > App content**
2. Complete required sections:
   - Privacy Policy URL (required)
   - Data safety
   - Target audience
   - Content ratings
3. Complete all required declarations

### Step 4: Upload Your First Release

1. Go to **Production** (or **Testing > Internal testing**)
2. Click **"Create new release"**
3. Upload your AAB file:
   - Click **"Upload"**
   - Select `build/app/outputs/bundle/release/app-release.aab`
   - Wait for upload to complete
4. Fill in **Release notes**:
   - What's new in this version
   - Bug fixes
   - New features
5. Click **"Save"**
6. Click **"Review release"**
7. Review and click **"Start rollout to Production"** (or testing track)

### Step 5: Testing Tracks

Google Play offers several testing tracks:

#### Internal Testing
- **Fastest**: Available within minutes
- **Up to 100 testers**
- **No review process**
- Good for: Quick internal testing

#### Closed Testing (Alpha/Beta)
- **Up to 20,000 testers**
- **Review required** (usually 1-3 days)
- **Can have multiple tracks**
- Good for: Beta testing with selected users

#### Open Testing
- **Unlimited testers**
- **Review required**
- **Public beta**
- Good for: Public beta testing

#### Production
- **Public release**
- **Review required** (1-7 days typically)
- **Available to everyone**
- Good for: Final release

## Version Management

### Version Code (Build Number)
- **Must increase** with each release
- **Integer only** (1, 2, 3, ...)
- **Cannot decrease**
- Set in `pubspec.yaml`: `version: 1.0.0+13` (13 is version code)

### Version Name
- **User-visible version** (e.g., "1.0.0")
- **Can be any string**
- **Can decrease** (but not recommended)
- Set in `pubspec.yaml`: `version: 1.0.0+13` (1.0.0 is version name)

## Common Issues & Solutions

### Issue: "Upload failed"
- **Solution**: Check AAB file size (max 150MB for AAB, 2GB expanded)
- **Solution**: Verify internet connection
- **Solution**: Try uploading via browser instead of command line

### Issue: "Version code already used"
- **Solution**: Increment build number in `pubspec.yaml`
- **Solution**: Rebuild AAB with new version code

### Issue: "App not signed"
- **Solution**: Use Google Play App Signing (recommended)
- **Solution**: Or configure manual signing (see above)

### Issue: "Missing privacy policy"
- **Solution**: Add privacy policy URL in Store listing
- **Solution**: Required for apps that collect user data

## Build Commands Reference

### Build AAB (for Google Play Store)
```bash
flutter build appbundle --release
```

### Build APK (for direct installation/testing)
```bash
flutter build apk --release
```

### Build Split APKs (for testing)
```bash
flutter build apk --split-per-abi --release
```

## File Locations

- **AAB (for Play Store)**: `build/app/outputs/bundle/release/app-release.aab`
- **APK (for direct install)**: `build/app/outputs/flutter-apk/app-release.apk`
- **Split APKs**: `build/app/outputs/flutter-apk/app-<abi>-release.apk`

## Best Practices

1. **Always test on real devices** before releasing
2. **Use internal testing** first to catch issues
3. **Increment version code** for every release
4. **Write clear release notes** for users
5. **Monitor crash reports** in Play Console
6. **Respond to user reviews** promptly
7. **Keep dependencies updated** for security
8. **Test on multiple Android versions** (API levels)

## Resources

- [Google Play Console](https://play.google.com/console)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [AAB Format Guide](https://developer.android.com/guide/app-bundle)

## Checklist Before Release

- [ ] App tested on multiple devices
- [ ] Version code incremented
- [ ] Release notes written
- [ ] Privacy policy added (if required)
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] App content declarations complete
- [ ] AAB built successfully
- [ ] Uploaded to testing track first
- [ ] Tested in testing track
- [ ] Ready for production release

---

**Need help?** Check the [Flutter Android Deployment Guide](https://docs.flutter.dev/deployment/android) or [Google Play Console Help](https://support.google.com/googleplay/android-developer).

