import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/client.dart';
import '../models/trip.dart' as models;
import '../models/staff.dart';
import '../services/trip_service.dart';
import '../services/filemaker_service.dart';
import '../services/auth_service.dart';
import '../services/offline_sync_service.dart';
import '../services/attendance_service.dart';
import '../utils/debug_logger.dart';
import '../widgets/sync_banner.dart';
import '../widgets/signature_capture_dialog.dart';
import 'stop_sheet_page.dart';

/// Driver home screen showing today's trip and client list
class DriverHomePage extends StatefulWidget {
  final Staff driver;
  
  const DriverHomePage({super.key, required this.driver});

  @override
  State<DriverHomePage> createState() {
    DebugLogger.log('🏗️ DriverHomePage.createState() for ${driver.name}');
    return _DriverHomePageState();
  }
}

class _DriverHomePageState extends State<DriverHomePage> {
  models.Trip? _todayTrip;
  List<Client> _assignedClients = [];
  Map<String, String> _clientStatus = {};
  bool _isLoading = true;
  String _selectedDirection = 'AM';
  TripService? _tripService;
  AttendanceService? _attendanceService;

  @override
  void initState() {
    super.initState();
    DebugLogger.log('🏠 DriverHomePage.initState() for ${widget.driver.name}');
    // Use a microtask to ensure the widget is fully mounted
    Future.microtask(() {
      if (mounted) {
        _loadTrip();
      } else {
        DebugLogger.warn('Widget not mounted, skipping _loadTrip()');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to TripService and AttendanceService changes to refresh status
    _tripService = Provider.of<TripService>(context, listen: false);
    _attendanceService = Provider.of<AttendanceService>(context, listen: false);
    
    // Remove existing listeners first to avoid duplicates
    _tripService?.removeListener(_onTripServiceChanged);
    _attendanceService?.removeListener(_onAttendanceServiceChanged);
    
    // Add listeners to refresh when stops/attendance change
    _tripService?.addListener(_onTripServiceChanged);
    _attendanceService?.addListener(_onAttendanceServiceChanged);
  }

  @override
  void dispose() {
    // Remove listeners
    _tripService?.removeListener(_onTripServiceChanged);
    _attendanceService?.removeListener(_onAttendanceServiceChanged);
    super.dispose();
  }

  void _onTripServiceChanged() {
    if (mounted && _todayTrip != null && _assignedClients.isNotEmpty) {
      _refreshClientStatus();
    }
  }

  void _onAttendanceServiceChanged() {
    // When attendance is deleted, refresh client status
    if (mounted && _todayTrip != null && _assignedClients.isNotEmpty) {
      _refreshClientStatus();
    }
  }

  Future<void> _refreshClientStatus() async {
    if (_todayTrip == null || _assignedClients.isEmpty) return;
    
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final updatedStatus = await tripService.getClientStatus(
        tripId: _todayTrip!.id!,
        clients: _assignedClients,
      );
      if (mounted) {
        setState(() {
          _clientStatus = updatedStatus;
        });
        DebugLogger.log('🔄 Client status refreshed: ${_clientStatus.length} clients');
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Error refreshing client status', e, stackTrace);
    }
  }

  Future<void> _loadTrip() async {
    DebugLogger.log('🔄 _loadTrip() called');
    setState(() => _isLoading = true);
    
    // Load clients FIRST (independent of trip loading)
    try {
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      final clients = await fileMakerService.getClients();
      if (mounted) {
        setState(() {
          _assignedClients = clients;
        });
      }
      DebugLogger.success('Loaded ${_assignedClients.length} clients');
    } catch (e, stackTrace) {
      DebugLogger.error('Error loading clients', e, stackTrace);
      // Continue with empty list if client loading fails
      if (mounted) {
        setState(() {
          _assignedClients = [];
        });
      }
    }
    
    // Then load trip (separate try-catch so client loading doesn't block trip loading)
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      
      // Load today's trip (don't create - only create when first pickup is recorded)
      _todayTrip = await tripService.getTodayTrip(
        driverId: widget.driver.id,
        direction: _selectedDirection,
      );
      
      if (_todayTrip == null) {
        // Check FileMaker for existing trip (in case it exists from previous session)
        DebugLogger.log('📅 No trip in local DB, checking FileMaker...');
        final today = DateTime.now();
        final dateStr = '${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}/${today.year}';
        final existingPrimaryKey = await fileMakerService.findTripPrimaryKey(
          widget.driver.id, 
          dateStr, 
          _selectedDirection
        );
        
        if (existingPrimaryKey != null && existingPrimaryKey.isNotEmpty) {
          DebugLogger.success('✅ Found existing trip in FileMaker: $existingPrimaryKey');
          // Load the trip from FileMaker
          final syncService = Provider.of<OfflineSyncService>(context, listen: false);
          _todayTrip = await tripService.createTodayTrip(
            driverId: widget.driver.id,
            direction: _selectedDirection,
            offlineSyncService: syncService,
            fileMakerService: fileMakerService,
          );
        } else {
          DebugLogger.log('📝 No trip exists yet - will be created on first pickup');
          // Don't create trip - it will be created when first pickup is recorded
        }
      } else {
        DebugLogger.log('✅ Found existing trip: ${_todayTrip!.id}');
        
        // Check if trip has temporary ID (starts with "trip_") and sync to get PrimaryKey
        if (_todayTrip!.id != null && _todayTrip!.id!.startsWith('trip_')) {
          DebugLogger.warn('⚠️ Trip has temporary ID, checking FileMaker for PrimaryKey...');
          final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
          final syncService = Provider.of<OfflineSyncService>(context, listen: false);
          
          // Format date for FileMaker search (MM/DD/YYYY)
          final dateStr = '${_todayTrip!.date.month.toString().padLeft(2, '0')}/${_todayTrip!.date.day.toString().padLeft(2, '0')}/${_todayTrip!.date.year}';
          
          // First, try to find existing trip in FileMaker
          var primaryKey = await fileMakerService.findTripPrimaryKey(
            _todayTrip!.driverId,
            dateStr,
            _todayTrip!.direction,
          );
          
          // Check if the PrimaryKey already exists in local database
          if (primaryKey != null && primaryKey.isNotEmpty) {
            final existingTripWithKey = await tripService.getTripById(primaryKey);
            if (existingTripWithKey != null) {
              // PrimaryKey already exists - check if it's for the same trip
              if (existingTripWithKey.direction != _todayTrip!.direction ||
                  existingTripWithKey.driverId != _todayTrip!.driverId ||
                  existingTripWithKey.date != _todayTrip!.date) {
                DebugLogger.warn('⚠️ PrimaryKey $primaryKey exists but for different trip');
                DebugLogger.warn('⚠️ Existing: driverId=${existingTripWithKey.driverId}, direction=${existingTripWithKey.direction}, date=${existingTripWithKey.date}');
                DebugLogger.warn('⚠️ Current: driverId=${_todayTrip!.driverId}, direction=${_todayTrip!.direction}, date=${_todayTrip!.date}');
                DebugLogger.log('Creating new trip in FileMaker instead...');
                primaryKey = await syncService.syncTripImmediately(_todayTrip!);
              } else {
                // Same trip - we can use this PrimaryKey
                DebugLogger.log('✅ PrimaryKey matches existing trip, will update');
              }
            }
          }
          
          // If not found or PrimaryKey doesn't match, sync the trip to create it
          if (primaryKey == null || primaryKey.isEmpty) {
            DebugLogger.log('Trip not found in FileMaker, syncing to create it...');
            primaryKey = await syncService.syncTripImmediately(_todayTrip!);
          }
          
          if (primaryKey != null && primaryKey.isNotEmpty) {
            // Double-check the PrimaryKey doesn't already exist for a different trip
            final existingTripWithKey = await tripService.getTripById(primaryKey);
            if (existingTripWithKey != null && 
                existingTripWithKey.id != _todayTrip!.id &&
                (existingTripWithKey.direction != _todayTrip!.direction ||
                 existingTripWithKey.driverId != _todayTrip!.driverId ||
                 !existingTripWithKey.date.isAtSameMomentAs(DateTime(
                   _todayTrip!.date.year,
                   _todayTrip!.date.month,
                   _todayTrip!.date.day,
                 )))) {
              DebugLogger.error('❌ Cannot update: PrimaryKey $primaryKey already exists for different trip', null);
              DebugLogger.warn('⚠️ Trip will keep temporary ID: ${_todayTrip!.id}');
            } else {
              DebugLogger.success('✅ Got PrimaryKey from FileMaker: $primaryKey');
              // Update trip and stops in database with PrimaryKey
              try {
                await tripService.updateTripId(_todayTrip!.id!, primaryKey);
                // Reload trip with new PrimaryKey
                _todayTrip = await tripService.getTodayTrip(
                  driverId: widget.driver.id,
                  direction: _selectedDirection,
                );
                DebugLogger.success('✅ Trip and stops updated with PrimaryKey: ${_todayTrip?.id}');
              } catch (e, stackTrace) {
                DebugLogger.error('❌ Error updating trip ID (UNIQUE constraint?)', e, stackTrace);
                DebugLogger.warn('⚠️ Trip will keep temporary ID: ${_todayTrip!.id}');
              }
            }
          } else {
            DebugLogger.warn('⚠️ Could not get PrimaryKey, trip will use temporary ID');
          }
        }
      }
      
      if (_todayTrip != null && _assignedClients.isNotEmpty) {
        // Sync stops from FileMaker to local database (to know which are completed)
        await tripService.syncStopsFromFileMaker(
          tripId: _todayTrip!.id!,
          fileMakerService: fileMakerService,
        );
        
        _clientStatus = await tripService.getClientStatus(
          tripId: _todayTrip!.id!,
          clients: _assignedClients,
        );
        DebugLogger.log('✅ Client status loaded: ${_clientStatus.length} clients');
      } else if (_assignedClients.isNotEmpty) {
        // No trip yet - all clients are "Not picked"
        _clientStatus = {
          for (var client in _assignedClients) client.id: 'Not picked'
        };
        DebugLogger.log('📝 No trip yet - all clients marked as "Not picked"');
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Error loading trip', e, stackTrace);
      if (mounted) {
        // Defer ScaffoldMessenger call until after the first frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading trip: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      DebugLogger.log('🔄 _loadTrip() complete');
    }
  }

  /// Check if user has admin role
  /// Supports: admin, Admin, ADMIN, supervisor, Supervisor, superadmin, SuperAdmin, etc.
  bool _isAdminRole() {
    final role = widget.driver.role?.trim().toLowerCase() ?? '';
    return role == 'admin' || role == 'supervisor' || role == 'superadmin';
  }

  Future<void> _handlePickup(Client client) async {
    // Check if signature is required for pickup based on staff settings
    SignatureResult? signatureResult;
    if (widget.driver.requiresPickupSignature) {
      signatureResult = await SignatureCaptureDialog.show(
        context,
        clientName: client.name,
        title: 'Check In Confirmation',
      );
      
      // User cancelled signature
      if (signatureResult == null) {
        return;
      }
    }
    
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final offlineSyncService = Provider.of<OfflineSyncService>(context, listen: false);
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      
      // Create trip if it doesn't exist (first pickup creates the trip)
      if (_todayTrip == null) {
        DebugLogger.log('📅 Creating trip for first pickup...');
        _todayTrip = await tripService.createTodayTrip(
          driverId: widget.driver.id,
          direction: _selectedDirection,
          offlineSyncService: offlineSyncService,
          fileMakerService: fileMakerService,
        );
        DebugLogger.success('✅ Trip created with PrimaryKey: ${_todayTrip?.id}');
      }
      
      // Use Base64 signature data for FileMaker storage
      await tripService.recordStop(
        tripId: _todayTrip!.id!,
        clientId: client.id,
        kind: 'pickup',
        signatureBase64: signatureResult?.base64Data,
        requireSignature: widget.driver.requiresPickupSignature,
        offlineSyncService: offlineSyncService,
        syncDirectly: true, // DEBUG: Write directly to FileMaker
      );
      
      await _loadTrip();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.driver.requiresPickupSignature 
                ? 'Check in recorded with signature' 
                : 'Check in recorded'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error recording pickup';
        if (e.toString().contains('location') || e.toString().contains('permission')) {
          errorMessage = 'Location permission is required to record stops.\nPlease enable location access in Settings.';
        } else {
          errorMessage = 'Error: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: (e.toString().contains('location') || e.toString().contains('permission'))
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () async {
                      await Permission.locationWhenInUse.request();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  Future<void> _handleDropoff(Client client) async {
    // Check if signature is required for dropoff based on staff settings
    SignatureResult? signatureResult;
    if (widget.driver.requiresDropoffSignature) {
      signatureResult = await SignatureCaptureDialog.show(
        context,
        clientName: client.name,
        title: 'Check Out Confirmation',
      );
      
      // User cancelled signature
      if (signatureResult == null) {
        return;
      }
    }
    
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final offlineSyncService = Provider.of<OfflineSyncService>(context, listen: false);
      
      // Use Base64 signature data for FileMaker storage
      await tripService.recordStop(
        tripId: _todayTrip!.id!,
        clientId: client.id,
        kind: 'dropoff',
        signatureBase64: signatureResult?.base64Data,
        requireSignature: widget.driver.requiresDropoffSignature,
        offlineSyncService: offlineSyncService,
        syncDirectly: true, // DEBUG: Write directly to FileMaker
      );
      
      await _loadTrip();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.driver.requiresDropoffSignature 
                ? 'Check out recorded with signature' 
                : 'Check out recorded'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error recording check out';
        if (e.toString().contains('location') || e.toString().contains('permission')) {
          errorMessage = 'Location permission is required to record stops. Please enable location access in Settings.';
        } else {
          errorMessage = 'Error: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status.startsWith('Dropped')) {
      return Colors.green;
    } else if (status.startsWith('Picked')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  /// Get initials from driver name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout? All pending data will be synced before logging out.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _logout();
    }
  }

  /// Perform logout
  Future<void> _logout() async {
    try {
      // Sync all pending items before logout
      if (mounted) {
        final syncService = Provider.of<OfflineSyncService>(context, listen: false);
        syncService.setContext(context);
        
        // Show syncing message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Syncing data before logout...'),
              ],
            ),
            duration: Duration(seconds: 30), // Long duration in case sync takes time
          ),
        );
        
        try {
          final syncResult = await syncService.syncAll();
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (syncResult.success && syncResult.successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Synced ${syncResult.successCount} item${syncResult.successCount != 1 ? 's' : ''} before logout'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          DebugLogger.error('Error syncing before logout', e, null);
          // Continue with logout even if sync fails
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        }
      }
      
      // Clear FileMaker session (if available)
      try {
        if (mounted) {
          final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
          await fileMakerService.logout();
        }
      } catch (e) {
        print('⚠️ FileMaker logout error (continuing anyway): $e');
        // Continue with logout even if FileMaker logout fails
      }
      
      // Logout from Laravel backend (revoke Sanctum token)
      try {
        await AuthService.logout();
      } catch (e) {
        print('⚠️ AuthService logout error (continuing anyway): $e');
        // Continue with logout even if AuthService logout fails
      }
    } catch (e) {
      print('⚠️ Logout error: $e');
    } finally {
      // Always navigate back to login page, even if logout fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DebugLogger.log('🎨 DriverHomePage.build() - isLoading: $_isLoading, clients: ${_assignedClients.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Route'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              _getInitials(widget.driver.name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          // Show switch to attendance button for Admin/Supervisor/superAdmin
          if (_isAdminRole())
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () {
                final staff = Staff(
                  id: widget.driver.id,
                  email: widget.driver.email,
                  passwordRaw: widget.driver.passwordRaw,
                  name: widget.driver.name,
                  role: widget.driver.role,
                  active: widget.driver.active,
                  allowManualEntry: widget.driver.allowManualEntry,
                );
                Navigator.pushReplacementNamed(
                  context,
                  '/attendance',
                  arguments: {'staff': staff},
                );
              },
              tooltip: 'Switch to Attendance',
            ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              if (_todayTrip != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StopSheetPage(tripId: _todayTrip!.id!),
                  ),
                );
                // Refresh client status when returning from StopSheetPage
                // (in case stops were deleted)
                if (mounted) {
                  await _loadTrip();
                }
              }
            },
            tooltip: 'View Trip Sheet',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final syncService = Provider.of<OfflineSyncService>(context, listen: false);
              syncService.setContext(context);
              
              // Show loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Syncing...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              
              final result = await syncService.syncAll();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.success
                          ? '✅ Synced ${result.successCount} item${result.successCount != 1 ? 's' : ''}${result.failureCount > 0 ? ' (${result.failureCount} failed)' : ''}'
                          : '❌ Sync failed: ${result.error ?? "Unknown error"}',
                    ),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'Sync Now',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncBanner(),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTrip,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route selector card (always show)
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Today\'s $_selectedDirection Route',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(value: 'AM', label: Text('AM')),
                                      ButtonSegment(value: 'PM', label: Text('PM')),
                                    ],
                                    selected: {_selectedDirection},
                                    onSelectionChanged: (Set<String> newSelection) {
                                      setState(() {
                                        _selectedDirection = newSelection.first;
                                      });
                                      _loadTrip();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (_todayTrip == null)
                                Text(
                                  'No pickups recorded yet',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (_todayTrip?.routeName != null)
                                Text(
                                  'Route: ${_todayTrip!.routeName}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Clients list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Assigned Clients',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_assignedClients.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No clients assigned',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assignedClients.length,
                          itemBuilder: (context, index) {
                            final client = _assignedClients[index];
                            final status = _clientStatus[client.id] ?? 'Not picked';
                            final statusColor = _getStatusColor(status);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                title: Text(client.name),
                                subtitle: Row(
                                  children: [
                                    // Status pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: !status.startsWith('Dropped')
                                    ? IconButton(
                                        icon: const Icon(Icons.check_circle),
                                        color: status.startsWith('Not picked') ? Colors.blue : Colors.green,
                                        onPressed: status.startsWith('Not picked')
                                            ? () => _handlePickup(client)
                                            : () => _handleDropoff(client),
                                        tooltip: status.startsWith('Not picked') ? 'Pick Up' : 'Drop Off',
                                      )
                                    : null,
                                isThreeLine: false,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

