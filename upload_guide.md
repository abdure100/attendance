# Upload Archive to TestFlight - Step by Step Guide

## Your Archive is Ready! ✅
- **Location**: `~/Library/Developer/Xcode/Archives/2025-11-20/Runner-2025-11-20-045758.xcarchive`
- **Team ID**: `44GY3MRW88` (matches your installed app)
- **Version**: `1.0.0+5`

## Steps to Upload:

### 1. Open Xcode Organizer
- Xcode should be opening now
- Go to **Window > Organizer** (or press `Cmd+Shift+9`)
- Click the **Archives** tab at the top

### 2. Find Your Archive
- Look for `Runner-2025-11-20-045758.xcarchive` (or the most recent one)
- It should be listed with today's date (Nov 20, 2025)

### 3. Distribute the App
- Select your archive
- Click **"Distribute App"** button (bottom right)

### 4. Choose Distribution Method
- Select **"App Store Connect"**
- Click **"Next"**

### 5. Choose Upload Option
- Select **"Upload"**
- Click **"Next"**

### 6. Select Distribution Options
- Choose **"Automatically manage signing"** (recommended)
- Xcode will handle certificates automatically
- Click **"Next"**

### 7. Review and Upload
- Review the app information:
  - Bundle ID: `com.sphereemr.attendance`
  - Version: `1.0.0`
  - Build: `5`
- Click **"Upload"**
- Wait for upload to complete (5-10 minutes)

### 8. Verify in App Store Connect
- Go to https://appstoreconnect.apple.com
- Navigate to your app > **TestFlight**
- Wait 10-30 minutes for processing
- Once processed, you can add testers!

## Troubleshooting

**If archive doesn't appear:**
- The archive is at: `~/Library/Developer/Xcode/Archives/2025-11-20/`
- You can drag it into Organizer window

**If upload fails:**
- Make sure you're logged into Xcode with the correct Apple ID
- Check that the team has App Store Connect access
- Verify bundle ID matches in App Store Connect
