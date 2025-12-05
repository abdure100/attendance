# What Happens After Uploading to TestFlight

## Step 1: Wait for Processing (10-30 minutes)

After you upload the archive from Xcode:
1. The upload will complete (5-10 minutes)
2. App Store Connect will process the build (10-30 minutes)
3. You'll receive an email when processing is complete

## Step 2: Check Build Status in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with `admin@sphereemr.com`
3. Click **"My Apps"**
4. Select your app: **"Attendance & Tripsheet"**
5. Click the **"TestFlight"** tab
6. Check the build status:
   - **Processing** = Still being processed
   - **Ready to Submit** = Ready to use
   - **Missing Compliance** = Need to answer export compliance questions

## Step 3: Export Compliance (If Required)

If you see "Missing Compliance":
1. Click on the build
2. Answer the export compliance questions:
   - **"Does your app use encryption?"** → Usually **"No"** for most apps
   - If yes, you may need to provide more details
3. Click **"Start Internal Testing"** or **"Submit for Review"**

## Step 4: Add Testers

### Internal Testers (Up to 100 people)
1. Go to **TestFlight** tab
2. Click **"Internal Testing"** (left sidebar)
3. Click **"+"** to add testers
4. Enter email addresses of testers
5. They'll receive an email invitation
6. Testers need to install the **TestFlight app** from the App Store

### External Testers (Up to 10,000 people)
1. Go to **TestFlight** tab
2. Click **"External Testing"** (left sidebar)
3. Create a new group or use default
4. Add the build to the group
5. Add testers (email addresses)
6. **Submit for Beta App Review** (required for external testing)
7. Review usually takes 24-48 hours

## Step 5: Testers Install and Test

1. Testers receive email invitation
2. They install **TestFlight app** from App Store (if not already installed)
3. They open TestFlight app
4. They accept the invitation
5. They can install and test your app
6. They can provide feedback through TestFlight

## Step 6: Monitor Feedback

1. In App Store Connect, go to **TestFlight** tab
2. Check **"Feedback"** section
3. Review crash reports and tester feedback
4. Fix issues and upload new builds as needed

## Step 7: Submit for App Store Review (Optional)

If you want to release to the App Store:
1. Go to **App Store** tab (not TestFlight)
2. Fill in app information:
   - Screenshots
   - Description
   - Keywords
   - Privacy policy URL
   - Support URL
3. Submit for review
4. Review process takes 1-3 days typically

## Quick Checklist After Upload:

- [ ] Wait for processing (10-30 min)
- [ ] Check build status in App Store Connect
- [ ] Answer export compliance questions (if needed)
- [ ] Add internal testers
- [ ] Send invitations to testers
- [ ] Testers install TestFlight app
- [ ] Testers install your app
- [ ] Monitor feedback and crashes
- [ ] Fix issues and upload new builds as needed

## Important Notes:

- **Builds expire after 90 days** - Upload new builds before expiration
- **External testing requires Beta App Review** - Takes 24-48 hours
- **Internal testing is immediate** - No review needed
- **Testers need iOS 13.0 or later** (based on your deployment target)
- **TestFlight app is free** - Testers download it from App Store

## Troubleshooting:

**Build stuck in "Processing"?**
- Wait up to 30 minutes
- Check email for any issues
- Sometimes takes longer for first build

**Testers can't install?**
- Make sure they have TestFlight app installed
- Check that build is not expired
- Verify tester email is correct
- Ensure iOS version is compatible

**Export compliance questions?**
- Most apps answer "No" to encryption question
- Only answer "Yes" if you use custom encryption
