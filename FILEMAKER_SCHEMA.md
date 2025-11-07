# FileMaker Database Schema for Transportation & Attendance App

This document outlines the FileMaker layouts/tables needed for the transportation and attendance tracking system.

## Overview

The app syncs three main entities to FileMaker:
1. **Trips** - Driver routes (AM/PM)
2. **Stops** - Individual pickup/dropoff events
3. **Attendance** - Time-in/out records

## Required Tables/Layouts

### 1. Trips Table (`api_trips`)

**Purpose:** Store driver routes for each day

**Fields:**
| Field Name | Type | Notes |
|------------|------|-------|
| `PrimaryKey` | Text (UUID) | Primary key, auto-generated |
| `date` | Date | Trip date |
| `routeName` | Text | Optional route identifier |
| `driverId` | Text (UUID) | Foreign key to `api_staffs` table |
| `vehicleId` | Text | Optional vehicle identifier |
| `direction` | Text | "AM" or "PM" |
| `status` | Text | "pending", "in_progress", "completed" |
| `CreationTimestamp` | Timestamp | Auto-managed by FileMaker |
| `ModificationTimestamp` | Timestamp | Auto-managed by FileMaker |

**Relationships:**
- `driverId` → `api_staffs::PrimaryKey` (many-to-one)

**Notes:**
- Create a layout named `api_trips` for API access
- Set `PrimaryKey` to auto-enter UUID
- `CreationTimestamp` and `ModificationTimestamp` are automatically managed by FileMaker - do NOT send these from the app
- The app will read these fields but should not include them in create/update operations

---

### 2. Stops Table (`api_stops`)

**Purpose:** Store individual pickup/dropoff events with GPS data

**Fields:**
| Field Name | Type | Notes |
|------------|------|-------|
| `PrimaryKey` | Text (UUID) | Primary key, auto-generated |
| `tripId` | Text (UUID) | Foreign key to `api_trips` |
| `clientId` | Text (UUID) | Foreign key to `api_patients` |
| `kind` | Text | "pickup" or "dropoff" |
| `plannedLatLng` | Text | "lat,lng" format (optional) |
| `actualLatLng` | Text | "lat,lng" format |
| `actualAddress` | Text | Reverse-geocoded address |
| `timestamp` | Timestamp | When stop occurred |
| `status` | Text | "pending" or "done" |
| `note` | Text | Optional notes |
| `photoPath` | Text | File path/URL to photo (optional) |
| `signaturePath` | Text | File path/URL to signature (optional) |
| `accuracy` | Number | GPS accuracy in meters |
| `speed` | Number | Speed in m/s |
| `CreationTimestamp` | Timestamp | Auto-managed by FileMaker |
| `ModificationTimestamp` | Timestamp | Auto-managed by FileMaker |

**Relationships:**
- `tripId` → `api_trips::PrimaryKey` (many-to-one)
- `clientId` → `api_patients::PrimaryKey` (many-to-one)

**Notes:**
- Create a layout named `api_stops` for API access
- Consider adding calculated fields for:
  - `latitude` (Number) - extracted from `actualLatLng`
  - `longitude` (Number) - extracted from `actualLatLng`
- Set `PrimaryKey` to auto-enter UUID
- `CreationTimestamp` and `ModificationTimestamp` are automatically managed by FileMaker - do NOT send these from the app

---

### 3. Attendance Table (`api_attendances`)

**Purpose:** Store time-in/out records for center staff

**Fields:**
| Field Name | Type | Notes |
|------------|------|-------|
| `PrimaryKey` | Text (UUID) | Primary key, auto-generated |
| `clientId` | Text (UUID) | Foreign key to `api_patients` |
| `date` | Date | Attendance date |
| `timeIn` | Timestamp | Time-in timestamp |
| `timeOut` | Timestamp | Time-out timestamp |
| `capturedBy` | Text (UUID) | Foreign key to `api_staffs` (staff who recorded) |
| `note` | Text | Optional notes |
| `CreationTimestamp` | Timestamp | Auto-managed by FileMaker |
| `ModificationTimestamp` | Timestamp | Auto-managed by FileMaker |

**Relationships:**
- `clientId` → `api_patients::PrimaryKey` (many-to-one)
- `capturedBy` → `api_staffs::PrimaryKey` (many-to-one)

**Notes:**
- Create a layout named `api_attendances` for API access
- Consider adding calculated fields:
  - `duration` (Number) - minutes between timeIn and timeOut
  - `isComplete` (Boolean) - true if both timeIn and timeOut exist
- Set `PrimaryKey` to auto-enter UUID
- `CreationTimestamp` and `ModificationTimestamp` are automatically managed by FileMaker - do NOT send these from the app

---

### 4. Patients Table (`api_patients`) - EXTENDED

**Purpose:** Patient information (already exists, but needs new fields)

**New Fields to Add:**
| Field Name | Type | Notes |
|------------|------|-------|
| `caregiverPhone` | Text | Caregiver contact phone |
| `homeLatLng` | Text | "lat,lng" format for home location |
| `homeAddress` | Text | Full address of client home |

**Existing Fields (already present):**
- `PrimaryKey` (UUID)
- `namefull` (Text)
- `address` (Text)
- `phone` (Text)
- `Email` (Text)
- `Company` (Text) - agency/company ID

**Notes:**
- These fields are optional but recommended for route planning
- `homeLatLng` can be used for route optimization

---

### 5. Staff Table (`api_staffs`) - VERIFY

**Purpose:** Staff/Driver information (should already exist)

**Required Fields:**
| Field Name | Type | Notes |
|------------|------|-------|
| `PrimaryKey` | UUID | Primary key |
| `email` | Text | Login email |
| `Password_raw` | Text | Password (for login) |
| `FullName` | Text | Staff full name |
| `role` | Text | "driver", "staff", "admin" |
| `active` | Boolean | Active status |

**Notes:**
- Verify `role` field exists and supports "driver" value
- Staff with `role = "driver"` will see Driver Home screen
- Staff with `role = "staff"` will see Attendance screen

---

## Relationships Graph

```
api_staffs (1) ──< (many) api_trips
api_trips (1) ──< (many) api_stops
api_patients (1) ──< (many) api_stops
api_patients (1) ──< (many) api_attendances
api_staffs (1) ──< (many) api_attendances (via capturedBy)
```

## API Access Setup

For each layout (`api_trips`, `api_stops`, `api_attendances`, `api_patients`):

1. **Enable Data API:**
   - File → Manage → Security → Privilege Sets
   - Ensure the API user has access to these layouts

2. **Layout Settings:**
   - Layout → Layout Setup → "Show Records in Layout" = All Records
   - Layout → Layout Setup → "Show Records in Layout" based on current user (optional)

3. **Field Access:**
   - Ensure all fields listed above are present on the layout
   - Field names must match exactly (case-sensitive)

4. **Scripts (Optional):**
   - `OnRecordCommit` - Update `modifiedAt` timestamp
   - `OnRecordCreate` - Validate data, set defaults

## Data Validation Rules

### Trips
- `direction` must be "AM" or "PM"
- `driverId` must reference valid staff with `role = "driver"`
- `date` cannot be in the future

### Stops
- `kind` must be "pickup" or "dropoff"
- `tripId` must reference valid trip
- `clientId` must reference valid patient
- `actualLatLng` must be in format "lat,lng" (e.g., "37.7749,-122.4194")
- `accuracy` should be > 0 and < 1000 (meters)
- Business rule: Can't have dropoff without pickup for same patient in same trip

### Attendance
- `clientId` must reference valid patient
- `capturedBy` must reference valid staff
- `date` cannot be in the future
- `timeOut` must be after `timeIn` (if both exist)
- Business rule: Can't have timeOut without timeIn

## Sync Implementation Notes

When implementing sync in `OfflineSyncService`:

1. **Create Operations:**
   - Use `POST /databases/{database}/layouts/{layout}/records`
   - Example: `POST /databases/EIDBI/layouts/api_trips/records`

2. **Update Operations:**
   - Use `PATCH /databases/{database}/layouts/{layout}/records/{recordId}`
   - Example: `PATCH /databases/EIDBI/layouts/api_trips/records/{PrimaryKey}`

3. **Field Mapping:**
   - Map Dart model fields to FileMaker field names exactly
   - Handle date/time conversions (FileMaker uses different format)
   - **DO NOT** send `CreationTimestamp` or `ModificationTimestamp` - these are auto-managed by FileMaker
   - The app uses `SyncHelpers` to prepare payloads, removing FileMaker-managed fields

4. **Error Handling:**
   - Check for duplicate records (same PrimaryKey)
   - Handle network timeouts
   - Retry logic is already implemented in `OfflineSyncService`

## Important Notes

### Timestamp Fields
- **DO NOT** send `CreationTimestamp` or `ModificationTimestamp` from the app
- FileMaker automatically manages these fields
- The app will read these fields when fetching records, but they are read-only from the app's perspective

### Validate Stop (Before Commit)

```filemaker
// If kind = "dropoff", check if pickup exists
If [ api_stops::kind = "dropoff" ]
    Set Variable [ $tripId ; api_stops::tripId ]
    Set Variable [ $clientId ; api_stops::clientId ]
    
    Perform Find [ api_stops::tripId = $tripId AND api_stops::clientId = $clientId AND api_stops::kind = "pickup" ]
    
    If [ Get(FoundCount) = 0 ]
        Show Custom Dialog [ "Error: Cannot drop off without pickup" ]
        Halt Script
    End If
End If
```

## Testing Checklist

- [ ] Create `api_trips` layout with all required fields
- [ ] Create `api_stops` layout with all required fields
- [ ] Create `api_attendances` layout with all required fields
- [ ] Add new fields to `api_patients` layout
- [ ] Verify `api_staffs` has `role` field
- [ ] Set up relationships between tables
- [ ] Enable Data API access for all layouts
- [ ] Test creating a trip via API
- [ ] Test creating a stop via API
- [ ] Test creating attendance via API
- [ ] Test updating records via API
- [ ] Verify UUID auto-generation works
- [ ] Verify timestamp auto-enter works

## Next Steps

1. Create the layouts in FileMaker
2. Implement sync methods in `lib/services/offline_sync_service.dart`
3. Add helper methods to `FileMakerService` for each entity
4. Test sync with real data
5. Monitor for sync errors and retries

