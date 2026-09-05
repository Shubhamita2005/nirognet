library;

// 1. Flutter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 2. Screens
import 'screens/get_started.dart';
import 'screens/login_page.dart';
import 'screens/login_as.dart';
import 'screens/profile_page.dart';
import 'screens/signup_page.dart';

// 3. AI Screen
import 'screens/ai_symptom_checker_two.dart';

// 4. Emergency Screens
import 'screens/emergency_assistant.dart';
import 'screens/emergency_assistance_offline.dart';

// 5. Main App Shell
//import 'main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NirogNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3ECFCF),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      // ✅ START APP WITH AUTH CHECK
      home: const AuthCheck(),

      // ✅ ROUTES
      routes: {
        // --- Onboarding / Auth ---
        '/get_started': (context) => WelcomeScreen(),
        '/login': (context) => LoginPage(),
        '/login_as': (context) => LoginScreen(),
        '/signup': (context) => SignUpPage(),


        // --- Main App ---


// --- Other Screens ---
'/ai_symptom': (context) => AISymptomChecker(),
'/profile': (context) => ProfilePage(),
'/emergency_assistant': (context) => EmergencyAssistantPage(),
'emergency_assistance_offline': (context) =>
    EmergencyAssessmentPage(),
      },
    );
  }
}


//////////////////////////////////////////////////////////
// ✅ AUTH CHECK SCREEN (AUTO LOGIN LOGIC)
//////////////////////////////////////////////////////////

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      String? token = await _storage.read(key: 'access_token');

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        print('🔁 User already logged in');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        print('🚪 No token found, go to onboarding');
        Navigator.pushReplacementNamed(context, '/get_started');
      }
    } catch (e) {
      print('❌ Error checking login: $e');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/get_started');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple loading screen while checking token
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}