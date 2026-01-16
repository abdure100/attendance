import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/filemaker_service.dart';
import '../services/auth_service.dart';
import '../utils/debug_logger.dart';
import '../models/staff.dart';
import '../config/app_config.dart';
import '../database/app_database.dart';
import 'driver_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true; // Default to remember credentials

  // Keys for SharedPreferences
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedUsername = 'saved_username';
  static const String _keySavedPassword = 'saved_password';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Load saved credentials if "Remember Me" was enabled
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      
      if (rememberMe) {
        final savedUsername = prefs.getString(_keySavedUsername);
        final savedPasswordEncoded = prefs.getString(_keySavedPassword);
        
        if (savedUsername != null && savedPasswordEncoded != null) {
          // Decode the password (simple base64 encoding for basic obfuscation)
          final savedPassword = _decodePassword(savedPasswordEncoded);
          
          setState(() {
            _usernameController.text = savedUsername;
            _passwordController.text = savedPassword;
            _rememberMe = true;
          });
          
          DebugLogger.info('📝 Loaded saved credentials for: $savedUsername');
        }
      }
    } catch (e) {
      DebugLogger.error('Error loading saved credentials', e);
    }
  }

  /// Save credentials if "Remember Me" is enabled
  Future<void> _saveCredentials(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberMe) {
        await prefs.setBool(_keyRememberMe, true);
        await prefs.setString(_keySavedUsername, username);
        // Encode the password (simple base64 encoding for basic obfuscation)
        await prefs.setString(_keySavedPassword, _encodePassword(password));
        DebugLogger.info('📝 Saved credentials for: $username');
      } else {
        // Clear saved credentials
        await prefs.remove(_keyRememberMe);
        await prefs.remove(_keySavedUsername);
        await prefs.remove(_keySavedPassword);
        DebugLogger.info('📝 Cleared saved credentials');
      }
    } catch (e) {
      DebugLogger.error('Error saving credentials', e);
    }
  }

  /// Simple password encoding (base64)
  String _encodePassword(String password) {
    return base64Encode(utf8.encode(password));
  }

  /// Simple password decoding (base64)
  String _decodePassword(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      
      // Step 1: Authenticate with FileMaker to get access
      DebugLogger.log('🔍 LOGIN: Step 1 - Authenticating with FileMaker...');
      DebugLogger.log('🔍 LOGIN: Database: ${AppConfig.database}, BaseURL: ${AppConfig.baseUrl}');
      await fileMakerService.authenticate();
      
      // Small delay to ensure token is fully set
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Step 2: Validate user credentials against staff table
      DebugLogger.log('🔍 LOGIN: Step 2 - Looking up staff with email: $email');
      DebugLogger.log('🔍 LOGIN: Using database: ${FileMakerService.database}');
      final staff = await fileMakerService.getStaffByEmail(email);
      
      if (staff == null) {
        DebugLogger.error('User not found for email: $email', null);
        throw Exception('User not found. Please check your email address or contact your administrator.');
      }
      
      DebugLogger.success('Staff found: ${staff.name} (ID: ${staff.id})');
      
      // Compare password with Password_raw field
      if (staff.passwordRaw != password) {
        throw Exception('Invalid password');
      }
      
      // Check if staff is active
      if (staff.active == false) {
        throw Exception('Account is inactive');
      }
      
      // Save credentials if "Remember Me" is enabled
      await _saveCredentials(email, password);
      
      // Step 2.5: Clear all local data for fresh start
      DebugLogger.log('🗑️ LOGIN: Step 2.5 - Clearing all local data...');
      try {
        final database = Provider.of<AppDatabase>(context, listen: false);
        
        // Clear stops first (foreign key to trips)
        await database.delete(database.stops).go();
        DebugLogger.log('   ✅ Cleared stops table');
        
        // Clear trips
        await database.delete(database.trips).go();
        DebugLogger.log('   ✅ Cleared trips table');
        
        // Clear outboxes (pending sync items)
        await database.delete(database.outboxes).go();
        DebugLogger.log('   ✅ Cleared outboxes table (pending sync items)');
        
        // Clear local attendance records
        await database.delete(database.attendances).go();
        DebugLogger.log('   ✅ Cleared attendances table');
        
        DebugLogger.success('✅ All local data cleared successfully');
      } catch (e, stackTrace) {
        DebugLogger.error('Error clearing local data', e, stackTrace);
        // Continue with login even if clearing fails
      }
      
      // Step 3: Exchange FileMaker token for Sanctum token (no re-authentication needed)
      DebugLogger.log('🔍 LOGIN DEBUG: Starting Step 3 - Token Exchange');
      try {
        // Get the FileMaker token that was just obtained
        final fileMakerToken = fileMakerService.token;
        DebugLogger.log('🔍 LOGIN DEBUG: FileMaker token retrieved');
        DebugLogger.log('🔍 LOGIN DEBUG: Token is null: ${fileMakerToken == null}');
        
        if (fileMakerToken != null && fileMakerToken.isNotEmpty) {
          DebugLogger.info('🔐 Exchanging FileMaker token for Sanctum token...');
          final sanctumToken = await AuthService.exchangeFileMakerToken(
            filemakerToken: fileMakerToken,
            email: email,
            database: AppConfig.database,
          );
          
          if (sanctumToken != null) {
            DebugLogger.success('Sanctum token obtained via FileMaker token exchange');
          } else {
            DebugLogger.warn('Sanctum token not received, but continuing with FileMaker auth');
            // Continue anyway - MCP features will fall back to direct API
          }
        } else {
          DebugLogger.warn('No FileMaker token available for exchange');
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Failed to exchange FileMaker token for Sanctum token', e, stackTrace);
        DebugLogger.warn('Continuing with FileMaker auth only - MCP features will use fallback');
        // Don't block login if Sanctum auth fails - user can still use the app
      }
      DebugLogger.log('🔍 LOGIN DEBUG: Step 3 completed');
      
      // Step 4: Navigate based on user role
      try {
        DebugLogger.log('🔍 LOGIN DEBUG: Step 4 - Starting navigation logic');
        if (mounted) {
          final rawRole = staff.role?.trim() ?? '';
          final role = rawRole.isEmpty ? '' : rawRole.toLowerCase();
          DebugLogger.log('🔍 LOGIN DEBUG: Staff role: "${staff.role}", normalized: "$role"');
          
          // Check if user has admin privileges (can access both layouts)
          // Supports: admin, Admin, ADMIN, supervisor, Supervisor, superadmin, SuperAdmin, etc.
          final isAdmin = role == 'admin' || role == 'supervisor' || role == 'superadmin';
          DebugLogger.log('🔍 LOGIN DEBUG: isAdmin: $isAdmin');
          
          // Allow SuperAdmin, driver, or empty role to access driver flow
          final isDriver = role == 'driver' || role == 'superadmin' || role.isEmpty;
          
          if (isAdmin) {
            // Show selection dialog for Admin/Supervisor/superAdmin
            DebugLogger.log('🔍 LOGIN DEBUG: Admin role detected, showing layout selection');
            _showLayoutSelectionDialog(staff);
          } else if (isDriver) {
            DebugLogger.log('🔍 LOGIN DEBUG: Routing to driver-home');
            try {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    DebugLogger.log('🚀 Creating DriverHomePage for ${staff.name}');
                    return DriverHomePage(driver: staff);
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              );
            } catch (e, stackTrace) {
              DebugLogger.error('Error navigating to DriverHomePage', e, stackTrace);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigation error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            DebugLogger.log('🚀 Routing to attendance page (not driver)');
            Navigator.pushReplacementNamed(
              context,
              '/attendance',
              arguments: {'staff': staff},
            );
          }
        } else {
          DebugLogger.warn('Widget not mounted, cannot navigate');
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Exception in Step 4 navigation', e, stackTrace);
        rethrow; // Re-throw to be caught by outer catch
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Exception in _login()', e, stackTrace);
      if (mounted) {
        // Show more detailed error message
        String errorMessage = 'Login failed';
        if (e.toString().contains('User not found')) {
          errorMessage = 'User not found. Please check your email address.';
        } else if (e.toString().contains('Invalid password')) {
          errorMessage = 'Invalid password. Please try again.';
        } else if (e.toString().contains('Account is inactive')) {
          errorMessage = 'Your account is inactive. Please contact your administrator.';
        } else if (e.toString().contains('FileMaker')) {
          errorMessage = 'Database connection error: ${e.toString()}';
        } else {
          errorMessage = 'Login failed: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Test accounts for quick login (db.sphereemr.com passwords)
  static const List<Map<String, String>> _testAccounts = [
    {'name': 'Driver 1', 'email': 'driver1@sunshinedp.com', 'password': 'Sunshinedp321\$'},
    {'name': 'Driver 2', 'email': 'driver2@sunshinedp.com', 'password': 'Sunshinedp321\$'},
    {'name': 'Sunshine Admin', 'email': 'info@sunshinedayprogram.com', 'password': 'Sunshinedp321\$'},
  ];

  /// Show debug information dialog
  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Debug Info'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _debugRow('App Version', AppConfig.appVersion),
              _debugRow('FM Base URL', AppConfig.baseUrl),
              _debugRow('FM Database', AppConfig.database),
              _debugRow('MCP Base URL', AppConfig.mcpBaseUrl),
              _debugRow('FM Username', AppConfig.username ?? 'Not set'),
              _debugRow('Sanctum Token', AppConfig.sanctumToken != null ? '${AppConfig.sanctumToken!.substring(0, 20)}...' : 'Not set'),
              const Divider(),
              _debugRow('Connection Timeout', '${AppConfig.connectionTimeout}s'),
              _debugRow('Receive Timeout', '${AppConfig.receiveTimeout}s'),
              const Divider(),
              const Text('Entered Credentials:', style: TextStyle(fontWeight: FontWeight.bold)),
              _debugRow('Email', _usernameController.text.isEmpty ? '(empty)' : _usernameController.text),
              _debugRow('Password', _passwordController.text.isEmpty ? '(empty)' : '****'),
              _debugRow('Remember Me', _rememberMe.toString()),
              const Divider(),
              const Text('Quick Fill Test Accounts:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._testAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _usernameController.text = account['email']!;
                        _passwordController.text = account['password']!;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Filled: ${account['name']}')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    child: Text(account['name']!, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy debug info to clipboard
              final debugText = '''
App Version: ${AppConfig.appVersion}
FM Base URL: ${AppConfig.baseUrl}
FM Database: ${AppConfig.database}
MCP Base URL: ${AppConfig.mcpBaseUrl}
FM Username: ${AppConfig.username ?? 'Not set'}
Email: ${_usernameController.text}
''';
              DebugLogger.log('📋 Debug Info:\n$debugText');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Debug info logged to console')),
              );
            },
            child: const Text('Log to Console'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Show layout selection dialog for Admin/Supervisor/superAdmin
  Future<void> _showLayoutSelectionDialog(Staff staff) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Layout - ${staff.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose which layout you want to access:'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'driver'),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Driver Route'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'attendance'),
                  icon: const Icon(Icons.access_time),
                  label: const Text('Attendance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      try {
        if (result == 'driver') {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return DriverHomePage(driver: staff);
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/attendance',
            arguments: {'staff': staff},
          );
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Error navigating after layout selection', e, stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                            // Logo
                            Image.asset(
                              'assets/images/sphere.png',
                              height: 200,
                              width: 200,
                              fit: BoxFit.contain,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        'Attendance & Tripsheet',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Realtime Data Collection',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),

                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: _isLoading ? null : (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : () {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                            child: const Text(
                              'Remember Me',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Debug Button
                      TextButton.icon(
                        onPressed: () => _showDebugInfo(),
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: const Text('Debug Info'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
