# How to Add Testers in App Store Connect

## Step-by-Step Instructions:

### Step 1: Go to App Store Connect
1. Open: https://appstoreconnect.apple.com
2. Sign in with `admin@sphereemr.com`

### Step 2: Navigate to Your App
1. Click **"My Apps"** in the top navigation
2. Select **"Attendance & Tripsheet"** (or your app name)

### Step 3: Go to TestFlight Tab
1. Click the **"TestFlight"** tab at the top
2. Wait for your build to finish processing (if still processing)

### Step 4: Add Internal Testers (Recommended First)

**Internal Testing** - Up to 100 people, immediate access, no review needed

1. In the left sidebar, click **"Internal Testing"**
2. If no group exists, click **"+"** to create a group (or use default)
3. Click on the group name
4. Click **"Add Testers"** or the **"+"** button
5. You have two options:

   **Option A: Add by Email**
   - Click **"Add Email Addresses"**
   - Enter email addresses (one per line or comma-separated)
   - Click **"Add"**
   - Testers will receive invitation emails

   **Option B: Add Existing Users**
   - Click **"Add Users"**
   - Select users from your App Store Connect team
   - Click **"Add"**

6. Make sure your build is added to the group:
   - Click **"Builds"** section
   - Click **"+"** to add a build
   - Select your processed build
   - Click **"Done"**

### Step 5: Add External Testers (Optional)

**External Testing** - Up to 10,000 people, requires Beta App Review

1. In the left sidebar, click **"External Testing"**
2. Click **"+"** to create a new group (or edit existing)
3. Name your group (e.g., "Beta Testers")
4. Add your build to the group
5. Click **"Add Testers"**
6. Enter email addresses
7. Click **"Submit for Beta App Review"** (required for external testing)
8. Review takes 24-48 hours

## Quick Visual Guide:

```
App Store Connect
  └─ My Apps
      └─ Attendance & Tripsheet
          └─ TestFlight Tab
              ├─ Internal Testing (left sidebar)
              │   └─ Click group → Add Testers → Enter emails
              └─ External Testing (left sidebar)
                  └─ Create group → Add Build → Add Testers → Submit for Review
```

## Important Notes:

- **Internal testers** get immediate access (no review)
- **External testers** need Beta App Review (24-48 hours)
- Testers must have **TestFlight app** installed on their iPhone/iPad
- Testers receive **email invitations**
- You can add testers before the build finishes processing
- Builds expire after **90 days** - upload new builds before expiration

## What Testers Need to Do:

1. Check their email for TestFlight invitation
2. Install **TestFlight app** from App Store (free)
3. Open TestFlight app
4. Accept the invitation
5. Install your app
6. Start testing!

## Troubleshooting:

**Can't see "Add Testers" button?**
- Make sure you're in a test group
- Click on the group name first
- Build must be processed (not still processing)

**Testers not receiving emails?**
- Check spam/junk folder
- Verify email addresses are correct
- Make sure build is added to the test group

**Want to remove testers?**
- Go to the test group
- Click on tester name
- Click "Remove" or "Remove from Group"
