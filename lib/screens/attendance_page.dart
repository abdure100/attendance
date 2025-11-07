import 'package:flutter/material.dart';
import 'driver_home_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/attendance.dart' as models;
import '../models/staff.dart';
import '../services/attendance_service.dart';
import '../services/filemaker_service.dart';
import '../services/auth_service.dart';
import '../utils/debug_logger.dart';

/// Attendance screen for center staff to record time-in/out
class AttendancePage extends StatefulWidget {
  final Staff staff;
  
  const AttendancePage({super.key, required this.staff});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Client> _clients = [];
  Map<String, models.Attendance> _attendanceMap = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final attendanceService = Provider.of<AttendanceService>(context, listen: false);
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      
      // Load all clients for the company
      DebugLogger.info('📋 Loading clients for attendance page...');
      try {
        _clients = await fileMakerService.getClients();
        DebugLogger.success('✅ Loaded ${_clients.length} clients');
      } catch (e, stackTrace) {
        DebugLogger.error('Error loading clients', e, stackTrace);
        // Continue with empty list if client loading fails
        _clients = [];
      }
      
      // Load today's attendance
      DebugLogger.info('📋 Loading today\'s attendance records...');
      final attendanceList = await attendanceService.getTodayAttendance();
      _attendanceMap = {
        for (var a in attendanceList) a.clientId: a,
      };
      DebugLogger.success('✅ Loaded ${_attendanceMap.length} attendance records');
    } catch (e, stackTrace) {
      DebugLogger.error('Error loading data', e, stackTrace);
      if (mounted) {
        // Defer ScaffoldMessenger call until after the first frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading data: $e'),
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
    }
  }

  Future<void> _handleTimeIn(Client client) async {
    try {
      final attendanceService = Provider.of<AttendanceService>(context, listen: false);
      
      await attendanceService.recordTimeIn(
        clientId: client.id,
        staffId: widget.staff.id,
      );
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time-in recorded'),
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

  Future<void> _handleTimeOut(Client client) async {
    try {
      final attendanceService = Provider.of<AttendanceService>(context, listen: false);
      
      await attendanceService.recordTimeOut(
        clientId: client.id,
        staffId: widget.staff.id,
      );
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time-out recorded'),
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

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    return _clients.where((client) =>
      client.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  /// Check if user has admin role
  /// Supports: admin, Admin, ADMIN, supervisor, Supervisor, superadmin, SuperAdmin, etc.
  bool _isAdminRole() {
    final role = widget.staff.role?.trim().toLowerCase() ?? '';
    return role == 'admin' || role == 'supervisor' || role == 'superadmin';
  }

  /// Get initials from staff name
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
        DebugLogger.warn('FileMaker logout error (continuing anyway): $e');
        // Continue with logout even if FileMaker logout fails
      }
      
      // Logout from Laravel backend (revoke Sanctum token)
      try {
        await AuthService.logout();
      } catch (e) {
        DebugLogger.warn('AuthService logout error (continuing anyway): $e');
        // Continue with logout even if AuthService logout fails
      }
    } catch (e) {
      DebugLogger.error('Logout error', e);
    } finally {
      // Always navigate back to login page, even if logout fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              _getInitials(widget.staff.name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          // Show switch to driver route button for Admin/Supervisor/superAdmin
          if (_isAdminRole())
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return DriverHomePage(driver: widget.staff);
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              },
              tooltip: 'Switch to Driver Route',
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Clients list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            final attendance = _attendanceMap[client.id];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                title: Text(client.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (attendance != null) ...[
                                      if (attendance.timeIn != null)
                                        Text(
                                          'Time In: ${DateFormat('HH:mm').format(attendance.timeIn!)}',
                                        ),
                                      if (attendance.timeOut != null)
                                        Text(
                                          'Time Out: ${DateFormat('HH:mm').format(attendance.timeOut!)}',
                                        ),
                                    ] else
                                      const Text('No attendance recorded'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (attendance == null || attendance.timeIn == null)
                                      IconButton(
                                        icon: const Icon(Icons.login),
                                        color: Colors.blue,
                                        onPressed: () => _handleTimeIn(client),
                                        tooltip: 'Time In',
                                      )
                                    else ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showEditAttendanceDialog(client, attendance),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => _showDeleteAttendanceDialog(client, attendance),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                    if (attendance != null &&
                                        attendance.timeIn != null &&
                                        attendance.timeOut == null)
                                      IconButton(
                                        icon: const Icon(Icons.logout),
                                        color: Colors.orange,
                                        onPressed: () => _handleTimeOut(client),
                                        tooltip: 'Time Out',
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAttendanceDialog(Client client, models.Attendance attendance) async {
    final noteController = TextEditingController(text: attendance.note ?? '');
    TimeOfDay? timeIn = attendance.timeIn != null ? TimeOfDay.fromDateTime(attendance.timeIn!) : null;
    TimeOfDay? timeOut = attendance.timeOut != null ? TimeOfDay.fromDateTime(attendance.timeOut!) : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Attendance - ${client.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Time In'),
                subtitle: Text(timeIn != null 
                    ? '${timeIn!.hour.toString().padLeft(2, '0')}:${timeIn!.minute.toString().padLeft(2, '0')}'
                    : 'Not set'),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: timeIn ?? TimeOfDay.now(),
                    );
                    if (time != null && mounted) {
                      timeIn = time;
                      Navigator.pop(context);
                      _showEditAttendanceDialog(client, attendance);
                    }
                  },
                ),
              ),
              if (timeIn != null)
                ListTile(
                  title: const Text('Time Out'),
                  subtitle: Text(timeOut != null 
                      ? '${timeOut!.hour.toString().padLeft(2, '0')}:${timeOut!.minute.toString().padLeft(2, '0')}'
                      : 'Not set'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: timeOut ?? TimeOfDay.now(),
                          );
                          if (time != null && mounted) {
                            timeOut = time;
                            Navigator.pop(context);
                            _showEditAttendanceDialog(client, attendance);
                          }
                        },
                      ),
                      if (timeOut != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            timeOut = null;
                            Navigator.pop(context);
                            _showEditAttendanceDialog(client, attendance);
                          },
                        ),
                    ],
                  ),
                ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final attendanceService = Provider.of<AttendanceService>(context, listen: false);
        final date = attendance.date;
        
        DateTime? updatedTimeIn;
        if (timeIn != null) {
          updatedTimeIn = DateTime(date.year, date.month, date.day, timeIn!.hour, timeIn!.minute);
        }
        
        DateTime? updatedTimeOut;
        if (timeOut != null) {
          updatedTimeOut = DateTime(date.year, date.month, date.day, timeOut!.hour, timeOut!.minute);
        }
        
        await attendanceService.updateAttendance(
          attendanceId: attendance.id!,
          timeIn: updatedTimeIn,
          timeOut: updatedTimeOut,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance updated'),
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
  }

  Future<void> _showDeleteAttendanceDialog(Client client, models.Attendance attendance) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: Text('Are you sure you want to delete the attendance record for ${client.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final attendanceService = Provider.of<AttendanceService>(context, listen: false);
        await attendanceService.deleteAttendance(attendance.id!);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance deleted'),
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
  }
}

