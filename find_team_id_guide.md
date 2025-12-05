# Step-by-Step Guide to Find Team ID for admin@sphereemr.com

## Method 1: Xcode Settings (Easiest)

1. **Open Xcode** (should be opening now)
2. Go to **Xcode > Settings** (or press `Cmd+,`)
3. Click the **Accounts** tab at the top
4. Look for `admin@sphereemr.com` in the left sidebar
5. Click on it to select it
6. On the right side, you'll see:
   - Team name (e.g., "Sphere EMR, Inc.")
   - **Team ID** - This is what you need! (e.g., `44GY3MRW88`)

## Method 2: In Project Settings

1. In Xcode, make sure `ios/Runner.xcworkspace` is open
2. In the left sidebar, click the **blue "Runner" project icon** (at the very top)
3. In the main area, under **TARGETS**, select **Runner**
4. Click the **Signing & Capabilities** tab
5. Look at the **Team** dropdown
6. Click the dropdown - you'll see teams listed
7. Each team shows:
   - Team name
   - **Team ID in parentheses** (e.g., "Sphere EMR (44GY3MRW88)")

## Method 3: Check Existing Archives

If you have any previous archives signed with admin@sphereemr.com:
```bash
plutil -p ~/Library/Developer/Xcode/Archives/*/Info.plist | grep -i team
```

## What the Team ID Looks Like

- Format: 10 uppercase letters and numbers
- Examples: `44GY3MRW88`, `RZW6S4A75D`, `ABC123XYZ`
- NOT an email address!

Once you find it, tell me the Team ID and I'll update the project!
