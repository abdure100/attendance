# TestFlight Distribution Guide

This guide explains how to build and distribute your app via TestFlight for beta testing.

## Prerequisites

1. **Apple Developer Account** (paid membership required)
   - Team ID: `44GY3MRW88`
   - Bundle ID: `com.sphereemr.attendance`

2. **App Store Connect Setup**
   - App must be created in App Store Connect
   - App Store Connect API access (optional, for automation)

3. **Xcode** (latest version recommended)

## Quick Start: Automated Script

The easiest way to prepare for TestFlight:

```bash
./build_testflight.sh
```

This will:
- Clean and build the app
- Update version numbers
- Open Xcode for archiving

## Manual Process

### Step 1: Update Version Number

Update `pubspec.yaml`:
```yaml
version: 1.0.1+2  # Version + Build Number
```

Or use the script:
```bash
./build_testflight.sh 1.0.1 2
```

### Step 2: Build the App

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build iOS release (no code signing)
flutter build ios --release --no-codesign
```

### Step 3: Create Archive in Xcode

1. **Open Xcode workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select target device:**
   - In Xcode, select "Any iOS Device" or "Generic iOS Device" from the device dropdown

3. **Create Archive:**
   - Go to **Product > Archive**
   - Wait for the build to complete (5-10 minutes)

4. **Organizer window opens automatically:**
   - Your archive will appear in the Organizer

### Step 4: Distribute to TestFlight

1. **In the Organizer window:**
   - Select your archive
   - Click **"Distribute App"**

2. **Choose distribution method:**
   - Select **"App Store Connect"**
   - Click **"Next"**

3. **Choose upload option:**
   - Select **"Upload"**
   - Click **"Next"**

4. **Select distribution options:**
   - ✅ Include bitcode: **No** (already set in exportOptions.plist)
   - ✅ Upload symbols: **Yes** (recommended for crash reports)
   - Click **"Next"**

5. **Select signing:**
   - Choose **"Automatically manage signing"** (recommended)
   - Or select your provisioning profile manually
   - Click **"Next"**

6. **Review and upload:**
   - Review the summary
   - Click **"Upload"**
   - Wait for upload to complete (5-15 minutes)

### Step 5: Process in App Store Connect

1. **Go to App Store Connect:**
   - Visit https://appstoreconnect.apple.com
   - Sign in with your Apple Developer account

2. **Navigate to your app:**
   - Select "My Apps"
   - Click on "Attendance" (or your app name)

3. **Go to TestFlight:**
   - Click on **"TestFlight"** tab
   - Wait for processing (10-30 minutes)
   - You'll see a yellow "Processing" status

4. **After processing completes:**
   - Build will show as "Ready to Submit"

### Step 6: Add Testers

#### Internal Testing (Up to 100 testers)

1. **Add Internal Testers:**
   - Go to **TestFlight > Internal Testing**
   - Click **"+"** to add testers
   - Add email addresses of team members
   - Select the build
   - Click **"Start Testing"**

2. **Testers receive email:**
   - They'll get an invitation email
   - They need to install TestFlight app
   - They can install your app from TestFlight

#### External Testing (Up to 10,000 testers)

1. **Create Test Group:**
   - Go to **TestFlight > External Testing**
   - Click **"+"** to create a new group
   - Name it (e.g., "Beta Testers")

2. **Add Build:**
   - Select your processed build
   - Click **"Next"**

3. **Submit for Review:**
   - Fill out "What to Test" information
   - Add test information (optional)
   - Click **"Submit for Review"**
   - Wait for Apple's review (usually 24-48 hours)

4. **After Approval:**
   - Add testers to the group
   - They'll receive invitation emails

## Troubleshooting

### Build Errors

**Error: "No signing certificate found"**
- Solution: Ensure you're logged into Xcode with your Apple Developer account
- Go to Xcode > Settings > Accounts
- Add your Apple ID
- Select your team

**Error: "Provisioning profile not found"**
- Solution: Use automatic signing in Xcode
- Or manually create provisioning profile in Apple Developer portal

**Error: "Archive failed"**
- Solution: Ensure you selected "Any iOS Device" not a simulator
- Clean build folder: Product > Clean Build Folder

### Upload Errors

**Error: "Invalid Bundle"**
- Solution: Check that version number is incremented
- Ensure bundle ID matches App Store Connect

**Error: "Missing Compliance"**
- Solution: Answer export compliance questions in App Store Connect
- Usually: "No" to encryption questions for standard apps

### TestFlight Issues

**Build stuck in "Processing"**
- Wait up to 30 minutes
- Check email for any issues
- Sometimes takes longer for first build

**Testers can't install**
- Ensure they have TestFlight app installed
- Check that build is not expired
- Verify tester email is correct

## Automated Upload (Optional)

If you want to automate the upload process, you can use `fastlane`:

1. **Install fastlane:**
   ```bash
   sudo gem install fastlane
   ```

2. **Initialize fastlane in iOS folder:**
   ```bash
   cd ios
   fastlane init
   ```

3. **Configure Fastfile** (see fastlane documentation)

4. **Upload:**
   ```bash
   fastlane beta
   ```

## Version Numbering

- **Version (CFBundleShortVersionString):** User-facing version (e.g., 1.0.0, 1.0.1)
- **Build Number (CFBundleVersion):** Internal build number (e.g., 1, 2, 3, 4...)

**Best Practice:**
- Increment version for major/minor releases
- Always increment build number for each TestFlight upload
- Format: `version: 1.0.1+5` (version + build)

## Current Configuration

- **Bundle ID:** `com.sphereemr.attendance`
- **Team ID:** `44GY3MRW88`
- **Signing:** Automatic
- **Export Options:** `ios/exportOptions.plist` (configured for app-store)

## Quick Reference Commands

```bash
# Build and prepare for TestFlight
./build_testflight.sh

# Build with specific version
./build_testflight.sh 1.0.1 5

# Open Xcode
open ios/Runner.xcworkspace

# Check current version
grep "^version:" pubspec.yaml
```

## Need Help?

- [Apple TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

