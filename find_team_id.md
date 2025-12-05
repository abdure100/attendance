# How to Find Team ID for admin@sphereemr.com

## Method 1: In Xcode Settings
1. Open Xcode
2. Go to **Xcode > Settings** (or **Preferences**)
3. Click **Accounts** tab
4. Find `admin@sphereemr.com` in the list
5. Click on it to expand
6. You'll see the **Team ID** (e.g., ABC123XYZ) next to the team name

## Method 2: In Project Settings
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project (blue icon)
3. Select **Runner** target
4. Go to **Signing & Capabilities** tab
5. Click the **Team** dropdown
6. Hover over or select the team for `admin@sphereemr.com`
7. The Team ID will be shown (usually in parentheses or next to the name)

## Method 3: Check App Store Connect
- Go to https://appstoreconnect.apple.com
- Sign in with `admin@sphereemr.com`
- The Team ID is usually shown in the URL or in account settings

Once you have the Team ID, run:
```bash
./update_team.sh <TEAM_ID>
```

Or tell me the Team ID and I'll update it for you.
