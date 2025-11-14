import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/debug_logger.dart';
import 'screens/login_page.dart';
import 'screens/start_visit_page.dart';
import 'screens/session_page.dart';
import 'screens/manual_session_page.dart';
import 'screens/completed_sessions_page.dart';
import 'screens/session_details_page.dart';
import 'screens/behaviors_page.dart';
import 'screens/mcp_test_page.dart';
import 'screens/driver_home_page.dart';
import 'screens/stop_sheet_page.dart';
import 'screens/attendance_page.dart';
import 'services/filemaker_service.dart';
import 'services/token_service.dart';
import 'services/trip_service.dart';
import 'services/attendance_service.dart';
import 'services/offline_sync_service.dart';
import 'providers/session_provider.dart';
import 'database/app_database.dart';
import 'models/staff.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    DebugLogger.success('✅ Environment variables loaded from .env');
  } catch (e) {
    DebugLogger.warn('⚠️ Could not load .env file: $e');
    DebugLogger.warn('⚠️ Using default values or null for environment variables');
  }
  
  DebugLogger.info('🚀 App starting - loading Sanctum token...');
  // Load Sanctum token at app startup
  final token = await TokenService.loadSanctumToken();
  if (token != null) {
    DebugLogger.success('Sanctum token loaded at startup: ${token.length} chars');
  } else {
    DebugLogger.warn('No Sanctum token found at startup');
  }
  
  // Initialize database
  final database = AppDatabase();
  
  runApp(AttendanceApp(database: database));
}

class AttendanceApp extends StatelessWidget {
  final AppDatabase database;
  
  const AttendanceApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FileMakerService>(create: (_) => FileMakerService()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProxyProvider2<AppDatabase, FileMakerService, TripService>(
          create: (_) => TripService(database, null),
          update: (_, db, fm, previous) => previous ?? TripService(db, fm),
        ),
        ChangeNotifierProxyProvider2<AppDatabase, FileMakerService, AttendanceService>(
          create: (_) => AttendanceService(database, null),
          update: (_, db, fm, previous) => previous ?? AttendanceService(db, fm),
        ),
        ChangeNotifierProxyProvider2<AppDatabase, FileMakerService, OfflineSyncService>(
          create: (_) => OfflineSyncService(database, null),
          update: (_, db, fm, previous) => previous ?? OfflineSyncService(db, fm),
        ),
      ],
      child: MaterialApp(
        title: 'Realtime Data Collection',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        home: const LoginPage(),
        routes: {
          '/start-visit': (context) => const StartVisitPage(),
          '/session': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return SessionPage(
              visit: args?['visit'],
              client: args?['client'],
            );
          },
          '/manual-session': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return ManualSessionPage(client: args?['client']);
          },
          '/completed-sessions': (context) => const CompletedSessionsPage(),
          '/session-details': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return SessionDetailsPage(session: args?['session']);
          },
          '/behaviors': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return BehaviorsPage(
              clientId: args?['clientId'],
              visitId: args?['visitId'],
            );
          },
          '/mcp-test': (context) => const MCPTestPage(),
          '/driver-home': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final staff = args?['staff'] as Staff?;
            if (staff == null) {
              return const LoginPage(); // Fallback to login if no staff
            }
            return DriverHomePage(driver: staff);
          },
          '/attendance': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final staff = args?['staff'] as Staff?;
            if (staff == null) {
              return const LoginPage(); // Fallback to login if no staff
            }
            return AttendancePage(staff: staff);
          },
          '/stop-sheet': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return StopSheetPage(tripId: args?['tripId'] ?? '');
          },
        },
      ),
    );
  }
}
