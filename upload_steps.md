# Upload Archive to TestFlight - Step by Step

## Your Archive is Ready! ✅
- **Team ID**: RZW6S4A75D (admin@sphereemr.com)
- **Version**: 1.0.0+6
- **Archive**: Runner-2025-11-20-051218.xcarchive

## Step-by-Step Upload Instructions:

### Step 1: Open Xcode Organizer
- In Xcode, go to **Window > Organizer** (or press `Cmd+Shift+9`)
- Click the **Archives** tab at the top

### Step 2: Find Your Archive
- Look for: **Runner-2025-11-20-051218** (or the most recent one)
- It should show today's date (Nov 20, 2025)
- If you don't see it, the archive is at:
  `~/Library/Developer/Xcode/Archives/2025-11-20/`

### Step 3: Distribute the App
- **Select** your archive (click on it)
- Click the **"Distribute App"** button (bottom right)

### Step 4: Choose Distribution Method
- Select **"App Store Connect"**
- Click **"Next"**

### Step 5: Choose Upload Option
- Select **"Upload"**
- Click **"Next"**

### Step 6: Select Distribution Options
- Choose **"Automatically manage signing"** (recommended)
- This will let Xcode handle certificates automatically
- Click **"Next"**

### Step 7: Review and Upload
- Review the information:
  - Bundle ID: `com.sphereemr.attendance`
  - Version: `1.0.0`
  - Build: `6`
  - Team: Should show RZW6S4A75D
- Click **"Upload"**
- Wait for upload to complete (5-10 minutes)

### Step 8: Verify in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Sign in with `admin@sphereemr.com`
3. Navigate to your app > **TestFlight** tab
4. Wait 10-30 minutes for processing
5. Once processed, you can:
   - Add internal testers
   - Add external testers
   - Submit for review

## Troubleshooting

**Archive not showing?**
- Open Finder
- Go to: `~/Library/Developer/Xcode/Archives/2025-11-20/`
- Drag the archive into Xcode Organizer

**Upload fails?**
- Make sure you're logged into Xcode with the correct Apple ID
- Check that the team has App Store Connect access
- Verify bundle ID matches in App Store Connect
