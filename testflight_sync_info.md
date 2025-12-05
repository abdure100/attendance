# TestFlight Automatic Sync - What Happens Automatically

## After Uploading Archive:

### ✅ Automatic Processes:

1. **Upload to App Store Connect**
   - Archive uploads automatically (5-10 minutes)
   - Processing happens automatically (10-30 minutes)
   - You get an email when processing completes

2. **Build Appears in TestFlight**
   - Once processed, build automatically appears in TestFlight tab
   - Status changes from "Processing" to "Ready to Submit"

### ❌ NOT Automatic (You Need to Do):

1. **Adding Build to Test Groups**
   - You must manually add the build to Internal/External test groups
   - Go to TestFlight → Internal Testing → Add Build

2. **Sending to Testers**
   - If build is already in a test group, testers get it automatically
   - If it's a NEW build, you need to add it to the test group first

3. **Updating Existing Testers**
   - If testers already have the app installed:
     - They get a notification in TestFlight app
     - They can update to the new build
   - This happens automatically once build is in their test group

## For Existing Testers:

### ✅ Automatic:
- **Notification** - Testers get notified in TestFlight app about new build
- **Update Available** - They see "Update" button in TestFlight
- **No Re-invitation Needed** - If they're already in the test group, they automatically get access

### Manual (Testers Do):
- Testers must open TestFlight app
- Testers must tap "Update" to install new version
- Testers don't need to re-accept invitation

## Summary:

**Automatic:**
- ✅ Upload and processing
- ✅ Build appears in TestFlight
- ✅ Notifications to existing testers
- ✅ Update availability shown

**Manual:**
- ❌ Add build to test groups (first time)
- ❌ Testers must tap "Update" in TestFlight app
- ❌ Add new testers (if needed)

## Quick Answer:

**For existing testers:** Yes, they automatically get notified and can update
**For new builds:** You need to add the build to test groups once, then it's automatic
