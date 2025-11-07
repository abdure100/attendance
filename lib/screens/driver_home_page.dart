import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/trip.dart' as models;
import '../models/staff.dart';
import '../services/trip_service.dart';
import '../services/filemaker_service.dart';
import '../services/auth_service.dart';
import '../utils/debug_logger.dart';
import '../widgets/sync_banner.dart';
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
      
      // Load or create today's trip
      _todayTrip = await tripService.getTodayTrip(
        driverId: widget.driver.id,
        direction: _selectedDirection,
      );
      
      if (_todayTrip == null) {
        DebugLogger.log('📅 No trip found, creating new trip...');
        _todayTrip = await tripService.createTodayTrip(
          driverId: widget.driver.id,
          direction: _selectedDirection,
        );
        DebugLogger.success('Created new trip: ${_todayTrip?.id}');
      } else {
        DebugLogger.log('✅ Found existing trip: ${_todayTrip!.id}');
      }
      
      if (_todayTrip != null && _assignedClients.isNotEmpty) {
        _clientStatus = await tripService.getClientStatus(
          tripId: _todayTrip!.id!,
          clients: _assignedClients,
        );
        DebugLogger.log('✅ Client status loaded: ${_clientStatus.length} clients');
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
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      
      await tripService.recordStop(
        tripId: _todayTrip!.id!,
        clientId: client.id,
        kind: 'pickup',
      );
      
      await _loadTrip();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup recorded'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDropoff(Client client) async {
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      
      await tripService.recordStop(
        tripId: _todayTrip!.id!,
        clientId: client.id,
        kind: 'dropoff',
      );
      
      await _loadTrip();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dropoff recorded'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dropped':
        return Colors.green;
      case 'Picked':
        return Colors.orange;
      default:
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
          content: const Text('Are you sure you want to logout? This will end your current session.'),
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
            onPressed: () {
              if (_todayTrip != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StopSheetPage(tripId: _todayTrip!.id!),
                  ),
                );
              }
            },
            tooltip: 'View Trip Sheet',
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
                      // Trip card
                      if (_todayTrip != null)
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
                                        'Today\'s ${_todayTrip!.direction} Route',
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
                                  'Date: ${DateFormat('MMM dd, yyyy').format(_todayTrip!.date)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (_todayTrip!.routeName != null)
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
                                trailing: status != 'Dropped'
                                    ? IconButton(
                                        icon: const Icon(Icons.check_circle),
                                        color: status == 'Not picked' ? Colors.blue : Colors.green,
                                        onPressed: status == 'Not picked'
                                            ? () => _handlePickup(client)
                                            : () => _handleDropoff(client),
                                        tooltip: status == 'Not picked' ? 'Pick Up' : 'Drop Off',
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

