# Setting Up admin@sphereemr.com for TestFlight

## Step 1: Add Account in Xcode

1. Open Xcode
2. Go to **Xcode > Settings** (or **Preferences**)
3. Click the **Accounts** tab
4. Click the **+** button at the bottom left
5. Select **Apple ID**
6. Enter: `admin@sphereemr.com`
7. Enter the password
8. Click **Sign In**

## Step 2: Verify Team

1. After signing in, you should see the team listed
2. Note the **Team ID** (it will be shown next to the team name)
3. Make sure this team has access to App Store Connect

## Step 3: Update Project Team

Once you know the Team ID, we'll update the project to use it.

## Step 4: Rebuild Archive

After updating the team, rebuild the archive with the correct signing.
