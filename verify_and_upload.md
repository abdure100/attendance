# Team Verification & TestFlight Upload Guide

## Current Configuration

**Active Team ID**: `RZW6S4A75D` (from build settings)
**Bundle ID**: `com.sphereemr.attendance`
**Version**: `1.0.0+3`
**Archive**: `Runner-2025-11-20-035210.xcarchive`

## Step 1: Verify Team in Xcode

1. Open Xcode
2. Open `ios/Runner.xcworkspace`
3. Select the **Runner** project in the left sidebar
4. Select the **Runner** target
5. Go to **Signing & Capabilities** tab
6. Check the **Team** dropdown - it should show your team name
7. Verify it matches your App Store Connect account

**Note**: The active team is `RZW6S4A75D`. Make sure this team:
- Has access to App Store Connect
- Has the correct provisioning profiles for `com.sphereemr.attendance`
- Is the team you want to use for TestFlight

## Step 2: Upload to TestFlight via Xcode Organizer

### Method A: Using Xcode Organizer (Recommended)

1. **Open Organizer**:
   - In Xcode: `Window > Organizer` (or `Cmd+Shift+9`)
   - Click the **Archives** tab

2. **Select Your Archive**:
   - Find `Runner-2025-11-20-035210.xcarchive` (or the most recent one)
   - It should be listed with today's date

3. **Distribute App**:
   - Click **Distribute App** button
   - Choose **App Store Connect**
   - Click **Next**

4. **Select Distribution Method**:
   - Choose **Upload**
   - Click **Next**

5. **Select Distribution Options**:
   - Choose **Automatically manage signing** (recommended)
   - Or select **Manually manage signing** if you have specific profiles
   - Click **Next**

6. **Review and Upload**:
   - Review the app information
   - Click **Upload**
   - Wait for the upload to complete (this may take several minutes)

7. **Verify in App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Navigate to your app > **TestFlight**
   - Wait 10-30 minutes for processing
   - Once processed, you can add testers

### Method B: Command Line Upload (Alternative)

If you prefer command line, you can use:

```bash
# Export the archive
xcodebuild -exportArchive \
  -archivePath ~/Library/Developer/Xcode/Archives/2025-11-20/Runner-2025-11-20-035210.xcarchive \
  -exportOptionsPlist ios/exportOptions.plist \
  -exportPath ./build/export

# Upload using altool (requires App Store Connect API key)
xcrun altool --upload-app \
  --type ios \
  --file "./build/export/Runner.ipa" \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

## Troubleshooting

### If Team Doesn't Match:
1. In Xcode, go to **Signing & Capabilities**
2. Change the **Team** dropdown to the correct team
3. Rebuild the archive if needed

### If Archive Not Showing in Organizer:
- The archive is at: `~/Library/Developer/Xcode/Archives/2025-11-20/`
- You can drag it into Organizer or rebuild

### If Upload Fails:
- Check that your Apple ID has App Manager or Admin access
- Verify the bundle ID matches in App Store Connect
- Ensure you have valid certificates and provisioning profiles

