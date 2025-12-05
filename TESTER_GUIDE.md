# TestFlight Tester Guide

This guide explains how testers can download and install your app from TestFlight.

## For Testers: How to Download the App

### Step 1: Install TestFlight App

Testers need to install the **TestFlight** app from the App Store first:

1. Open the **App Store** on their iPhone/iPad
2. Search for **"TestFlight"**
3. Install the **TestFlight** app (it's free, made by Apple)

### Step 2: Accept Invitation

There are two ways testers can get access:

#### Option A: Email Invitation (Most Common)

1. **Tester receives email:**
   - Email subject: "You've been invited to test [App Name]"
   - Sent from: `no-reply@email.apple.com`
   - Contains invitation link

2. **Open invitation:**
   - Tap the link in the email on their iPhone/iPad
   - Or copy the link and open in Safari
   - This will open the TestFlight app automatically

3. **Accept invitation:**
   - Tap **"Accept"** in TestFlight
   - App will be added to their TestFlight library

#### Option B: Public Link (External Testing Only)

1. **Tester receives public link:**
   - You share a public TestFlight link
   - Format: `https://testflight.apple.com/join/XXXXXX`

2. **Open link:**
   - Tap the link on iPhone/iPad
   - Opens TestFlight app
   - Shows app information

3. **Start testing:**
   - Tap **"Start Testing"** or **"Accept"**
   - App is added to their TestFlight library

### Step 3: Install the App

1. **Open TestFlight app:**
   - Launch the **TestFlight** app on their device
   - Your app will appear in the list

2. **Install app:**
   - Tap on your app (e.g., "Sphere Attendance")
   - Tap **"Install"** button
   - App downloads and installs like a normal app

3. **Launch app:**
   - Once installed, tap **"Open"** in TestFlight
   - Or find the app icon on their home screen
   - Launch it like any other app

## What Testers See

### In TestFlight App:

- **List of apps** they're testing
- **App status** (Ready to Test, Expired, etc.)
- **Version information** (version number, build number)
- **What to Test** notes (if you provided them)
- **Feedback button** to send you feedback

### On Home Screen:

- App appears with a **orange dot** badge
- This indicates it's a TestFlight build
- Otherwise looks and works like a normal app

## Updating the App

When you release a new build:

1. **Testers receive notification:**
   - Push notification: "A new version of [App Name] is available"
   - Or email notification (if enabled)

2. **Update in TestFlight:**
   - Open TestFlight app
   - App shows **"Update"** button
   - Tap to update (downloads new version)

3. **Automatic updates (optional):**
   - Testers can enable auto-update in TestFlight settings
   - New versions install automatically

## Types of Testing

### Internal Testing (Up to 100 testers)

- **Who:** Team members, employees
- **Access:** Immediate (no Apple review)
- **Invitation:** Email from App Store Connect
- **Best for:** Quick internal testing

### External Testing (Up to 10,000 testers)

- **Who:** Anyone with the link
- **Access:** Requires Apple review (24-48 hours)
- **Invitation:** Email or public link
- **Best for:** Beta testing with customers/users

## Troubleshooting for Testers

### "Invitation Expired"

- **Problem:** Invitation link expired (90 days)
- **Solution:** Request a new invitation from the developer

### "App Not Available"

- **Problem:** Build expired or removed
- **Solution:** Developer needs to upload a new build

### "Can't Install"

- **Problem:** Device not compatible or iOS version too old
- **Solution:** Check minimum iOS version requirement

### "TestFlight App Not Opening"

- **Problem:** Link not opening TestFlight
- **Solution:** 
  - Make sure TestFlight is installed
  - Open link in Safari, not other browsers
  - Copy link and paste in Safari

### "App Crashes"

- **Problem:** Bug in the app
- **Solution:** 
  - Use **"Send Feedback"** button in TestFlight
  - Report the issue to the developer
  - Include steps to reproduce

## Tester Requirements

- **iOS Device:** iPhone or iPad
- **iOS Version:** Must meet minimum requirement (usually iOS 13.0+)
- **TestFlight App:** Must be installed
- **Apple ID:** Must be signed in to App Store
- **Internet:** Required for download and updates

## Privacy and Data

- TestFlight apps are **sandboxed** like regular apps
- Testers' data is **private** to them
- Developers can see **crash reports** and **feedback**
- Testers can **delete the app** anytime
- Testers can **stop testing** in TestFlight settings

## Feedback and Reporting Issues

Testers can provide feedback in two ways:

### 1. In-App Feedback (Recommended)

1. Open TestFlight app
2. Tap on your app
3. Tap **"Send Feedback"**
4. Choose feedback type:
   - **General Feedback**
   - **Report a Problem**
   - **Suggest an Improvement**
5. Add description and screenshots
6. Submit

### 2. Screenshots and Screen Recording

- TestFlight can capture screenshots
- Can record screen while using app
- Automatically attached to feedback

## Best Practices for Testers

1. **Keep TestFlight updated** - Install TestFlight app updates
2. **Enable notifications** - Get notified of new builds
3. **Provide feedback** - Report bugs and issues
4. **Test thoroughly** - Try different features
5. **Update promptly** - Install new builds when available
6. **Read "What to Test"** - Follow testing instructions

## Example Invitation Email

Testers will receive an email like this:

```
Subject: You've been invited to test Sphere Attendance

Hello,

You've been invited to test Sphere Attendance in TestFlight.

[App Icon]

Sphere Attendance
Version 1.0.0 (2)

Start Testing
[Button/Link]

This invitation will expire in 90 days.

What to Test:
- Login functionality
- Trip recording
- Attendance tracking
- Sync features

If you have questions, contact the developer.
```

## Quick Reference

**For Testers:**
1. Install TestFlight from App Store
2. Accept invitation (email or link)
3. Install app in TestFlight
4. Use app normally
5. Update when new builds available
6. Send feedback if issues found

**For Developers:**
- See `TESTFLIGHT_GUIDE.md` for distribution instructions
- Add testers in App Store Connect
- Share public links for external testing
- Monitor feedback and crash reports

## Need Help?

- **TestFlight Support:** https://developer.apple.com/testflight/
- **TestFlight App Help:** Open TestFlight app > Help
- **Contact Developer:** Use feedback feature in TestFlight

