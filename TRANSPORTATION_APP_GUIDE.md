# Transportation & Attendance App - Implementation Guide

## Overview

This app has been transformed from an ABA data collection app into a **transportation and attendance tracking system** for drivers and center staff.

## Architecture

### Core Data Models

1. **Trip** - Represents a driver's route for a day (AM/PM)
2. **Stop** - Individual pickup/dropoff events with GPS, timestamp, address
3. **Attendance** - Time-in/out records for center staff
4. **Outbox** - Queue for offline sync to FileMaker
5. **Client** - Extended with `caregiverPhone`, `homeLatLng`, `homeAddress`

### Key Services

1. **TripService** - Manages trips and stops
   - Auto-creates trip when driver starts route
   - Records pickups/dropoffs with GPS validation
   - Enforces business rules (can't drop without pickup)

2. **AttendanceService** - Manages time-in/out
   - Records time-in/out with validation
   - Enforces time-out requires time-in

3. **OfflineSyncService** - Handles offline queuing and sync
   - Queues all operations when offline
   - Syncs to FileMaker when online
   - Retry logic with max attempts

4. **LocationService** - GPS and geocoding
   - Gets current location with accuracy/speed
   - Reverse geocodes to address
   - Validates GPS accuracy (spoofing protection)

### Database

- **SQLite (Drift)** - Local offline storage
- Tables: `trips`, `stops`, `attendances`, `outboxes`
- All operations work offline
- Auto-queues for sync when online

## User Flows

### Driver Flow (Morning Route)

1. Login → Auto-routes to Driver Home if role is "driver"
2. Driver Home shows:
   - Today's trip card (AM/PM selector)
   - List of assigned clients with status pills
   - Action buttons (Pick Up / Drop Off)
3. Tap "Pick Up" → Records GPS, timestamp, address
4. Tap "Drop Off" → Records GPS, timestamp, address
5. View Trip Sheet → Chronological log of all stops

### Center Staff Flow

1. Login → Auto-routes to Attendance page if role is "staff"
2. Attendance page shows:
   - Searchable list of clients
   - Time-in/out buttons
   - Status indicators
3. Tap "Time In" → Records timestamp
4. End of day → Tap "Time Out" per client

### Sync Flow

- All operations save locally first (offline-capable)
- Sync banner shows pending items count
- Manual "Sync Now" button syncs all pending items
- Auto-retries failed syncs (max 5 attempts)

## Business Rules & Validations

✅ **Can't Drop Off without Pick Up** - Enforced in `TripService.recordStop()`  
✅ **Time-Out requires Time-In** - Enforced in `AttendanceService.recordTimeOut()`  
✅ **GPS Accuracy Validation** - Flags if accuracy > 100m (spoofing protection)  
✅ **Offline Queue** - All operations queued when offline, synced when online

## Next Steps / TODO

### 1. Generate Code Files

Run these commands to generate required files:

```bash
# Generate JSON serialization files
flutter pub run build_runner build --delete-conflicting-outputs

# Generate Drift database files
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. FileMaker Integration

The `OfflineSyncService` has placeholder methods for syncing to FileMaker. You need to:

1. Create FileMaker layouts/tables for:
   - `Trips` table
   - `Stops` table  
   - `Attendance` table

2. Implement sync methods in `OfflineSyncService`:
   - `_syncTrip()` - Create/update trip in FileMaker
   - `_syncStop()` - Create/update stop in FileMaker
   - `_syncAttendance()` - Create/update attendance in FileMaker

3. Extend `FileMakerService` with methods like:
   - `createTrip(Trip trip)`
   - `createStop(Stop stop)`
   - `createAttendance(Attendance attendance)`

### 4. Client Assignment Logic

In `DriverHomePage`, the `_assignedClients` list is currently empty. You need to:

- Add method to `FileMakerService`: `getAssignedClients(String driverId)`
- Load clients assigned to the driver for today's route
- Filter by trip direction (AM/PM)

### 5. Photo & Signature Capture

The `Stop` model has `photoPath` and `signaturePath` fields, but capture UI isn't implemented yet. Add:

- Image picker for photos
- Signature pad widget for signatures
- Save to local storage and include in sync

### 6. Permissions Setup

Update iOS `Info.plist` and Android `AndroidManifest.xml` with:
- Location permissions
- Camera permissions
- Storage permissions

### 7. Testing

- Test offline functionality
- Test GPS accuracy validation
- Test business rule validations
- Test sync retry logic
- Test role-based navigation

## File Structure

```
lib/
├── models/
│   ├── trip.dart              # NEW - Trip model
│   ├── stop.dart               # NEW - Stop model
│   ├── attendance.dart         # NEW - Attendance model
│   ├── outbox.dart             # NEW - Outbox model
│   └── client.dart             # UPDATED - Added transport fields
├── services/
│   ├── trip_service.dart       # NEW - Trip management
│   ├── attendance_service.dart  # NEW - Attendance management
│   ├── offline_sync_service.dart # NEW - Offline sync
│   └── location_service.dart   # UPDATED - Full GPS implementation
├── screens/
│   ├── driver_home_page.dart   # NEW - Driver home
│   ├── stop_sheet_page.dart    # NEW - Trip sheet
│   ├── attendance_page.dart    # NEW - Staff attendance
│   └── login_page.dart         # UPDATED - Role-based routing
├── widgets/
│   └── sync_banner.dart        # NEW - Sync status banner
└── database/
    └── app_database.dart       # NEW - Drift SQLite schema
```

## Reused Components

✅ **Login System** - Works as-is, just routes differently  
✅ **FileMakerService** - Can be extended for sync operations  
✅ **AuthService** - Token management unchanged  
✅ **Provider State Management** - Same pattern

## Notes

- The app maintains backward compatibility with existing ABA features
- All new features work offline-first
- Sync happens in background when online
- GPS spoofing protection via accuracy validation
- Business rules enforced at service layer

