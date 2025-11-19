import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/filemaker_service.dart';
import '../services/auth_service.dart';
import '../utils/debug_logger.dart';
import '../models/staff.dart';
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

  @override
  void initState() {
    super.initState();
    // User must enter their own credentials
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
      await fileMakerService.authenticate();
      
      // Small delay to ensure token is fully set
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Step 2: Validate user credentials against staff table
      DebugLogger.log('🔍 LOGIN: Looking up staff with email: $email');
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
            database: 'EIDBI',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                              height: 500,
                              width: 500,
                              fit: BoxFit.contain,
                            ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 24),

                      // Quick Login Buttons - Hidden
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: OutlinedButton(
                      //         onPressed: _isLoading ? null : () {
                      //           _usernameController.text = 'sacdiya@sphereemr.com';
                      //           _passwordController.text = 'Welcome123\$';
                      //         },
                      //         style: OutlinedButton.styleFrom(
                      //           padding: const EdgeInsets.symmetric(vertical: 12),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //         ),
                      //         child: const Text(
                      //           'Sacdiya - Staff',
                      //           style: TextStyle(fontSize: 14),
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: OutlinedButton(
                      //         onPressed: _isLoading ? null : () {
                      //           _usernameController.text = 'aisha@sphereemr.com';
                      //           _passwordController.text = 'Welcome123\$';
                      //         },
                      //         style: OutlinedButton.styleFrom(
                      //           padding: const EdgeInsets.symmetric(vertical: 12),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //         ),
                      //         child: const Text(
                      //           'Aisha - Driver',
                      //           style: TextStyle(fontSize: 14),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),

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
                      // MCP Test button hidden
                      // const SizedBox(height: 8),
                      // TextButton.icon(
                      //   onPressed: () => Navigator.pushNamed(context, '/mcp-test'),
                      //   icon: const Icon(Icons.science, size: 18),
                      //   label: const Text('MCP API Test'),
                      //   style: TextButton.styleFrom(
                      //     foregroundColor: Colors.grey[600],
                      //   ),
                      // ),
                      const SizedBox(height: 16),
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
