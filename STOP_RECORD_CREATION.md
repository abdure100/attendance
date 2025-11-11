# Stop Record Creation Guide

## Overview

When a staff member clicks "Pick Up" on a client in the Driver Route, the app creates a **Stop** record in FileMaker's `api_stops` table.

## What Gets Created

### Table: `api_stops`

When you click "Pick Up", the following record is created:

| Field Name | Value | Notes |
|------------|-------|-------|
| `PrimaryKey` | Auto-generated UUID | FileMaker auto-generates this |
| `tripId` | Trip ID | Links to the trip for today's route |
| `clientId` | Client ID | Links to the client being picked up |
| `kind` | `"pickup"` | Or `"dropoff"` when dropping off |
| `actualLatLng` | `"lat,lng"` | GPS coordinates (e.g., "44.9537,-93.0900") |
| `actualAddress` | Address string | Reverse-geocoded address from GPS |
| `timestamp` | ISO 8601 timestamp | When the pickup occurred (format: "2024-01-15T10:30:00") |
| `status` | `"done"` | Status of the stop |
| `note` | Optional text | Any notes added |
| `photoPath` | Optional text | Path to photo if taken |
| `signaturePath` | Optional text | Path to signature if collected |
| `accuracy` | Number | GPS accuracy in meters |
| `speed` | Number | Speed in m/s |
| `CreationTimestamp` | Auto-managed | FileMaker sets this automatically |
| `ModificationTimestamp` | Auto-managed | FileMaker sets this automatically |

## Flow

1. **User clicks "Pick Up"** on a client in Driver Route
2. **App gets GPS location** using LocationService
3. **App reverse geocodes** the address
4. **App creates Stop record locally** in SQLite database
5. **App queues for sync** to FileMaker
6. **Sync service creates record** in FileMaker's `api_stops` table

## FileMaker Setup Requirements

### Layout: `api_stops`

Create a layout named `api_stops` with the following fields:

1. **PrimaryKey** (Text)
   - Auto-enter: UUID
   - Required: Yes
   - Indexed: Yes

2. **tripId** (Text)
   - Required: Yes
   - Relationship: → `api_trips::PrimaryKey`

3. **clientId** (Text)
   - Required: Yes
   - Relationship: → `api_patients::PrimaryKey`

4. **kind** (Text)
   - Required: Yes
   - Values: "pickup" or "dropoff"

5. **actualLatLng** (Text)
   - Format: "lat,lng" (e.g., "44.9537,-93.0900")
   - Required: Yes

6. **actualAddress** (Text)
   - Optional

7. **timestamp** (Timestamp)
   - Required: Yes
   - Format: ISO 8601 (e.g., "2024-01-15T10:30:00")

8. **status** (Text)
   - Required: Yes
   - Values: "pending" or "done"

9. **note** (Text)
   - Optional

10. **photoPath** (Text)
    - Optional

11. **signaturePath** (Text)
    - Optional

12. **accuracy** (Number)
    - Optional
    - Units: meters

13. **speed** (Number)
    - Optional
    - Units: m/s

14. **CreationTimestamp** (Timestamp)
    - Auto-enter: Creation timestamp
    - Do NOT send from app

15. **ModificationTimestamp** (Timestamp)
    - Auto-enter: Modification timestamp
    - Do NOT send from app

## Verification Steps

1. **Check if layout exists:**
   - Open FileMaker
   - Verify `api_stops` layout exists
   - Verify all fields are present

2. **Check field names:**
   - Field names must match exactly (case-sensitive)
   - Use camelCase: `tripId`, `clientId`, `actualLatLng`, etc.

3. **Test the sync:**
   - Click "Pick Up" on a client
   - Check app logs for sync messages
   - Look for: `"✅ Stop created successfully in FileMaker"`
   - If you see `"❌ Stop creation returned null recordId"`, check FileMaker error logs

4. **Verify in FileMaker:**
   - Open `api_stops` layout
   - Look for the new record
   - Verify all fields are populated correctly

## Troubleshooting

### Issue: "Stop creation returned null recordId"

**Possible causes:**
1. Layout `api_stops` doesn't exist
2. Field names don't match (check case sensitivity)
3. Required fields are missing
4. Field types don't match (e.g., timestamp format)
5. FileMaker Data API permissions issue

**Solution:**
1. Check app logs for detailed error messages
2. Verify layout and field names in FileMaker
3. Check FileMaker Data API error logs
4. Verify Data API access is enabled for `api_stops` layout

### Issue: Stop shows as "Picked" but no record in FileMaker

**Possible causes:**
1. Sync hasn't run yet (offline mode)
2. Sync failed silently
3. Network connectivity issue

**Solution:**
1. Check sync status in app (look for sync banner)
2. Manually trigger sync if available
3. Check app logs for sync errors
4. Verify internet connection

## Code References

- **Stop Model:** `lib/models/stop.dart`
- **Sync Service:** `lib/services/offline_sync_service.dart` → `_syncStop()`
- **Trip Service:** `lib/services/trip_service.dart` → `recordStop()`
- **FileMaker Service:** `lib/services/filemaker_service.dart` → `createRecord()`

## Example Stop Record

```json
{
  "tripId": "trip_driver123_1705320000000_AM",
  "clientId": "client-uuid-123",
  "kind": "pickup",
  "actualLatLng": "44.9537,-93.0900",
  "actualAddress": "123 Main St, Minneapolis, MN 55401",
  "timestamp": "2024-01-15T10:30:00",
  "status": "done",
  "accuracy": 5.2,
  "speed": 0.0
}
```

Note: `PrimaryKey` is NOT sent - FileMaker auto-generates it.

