import 'package:flutter/material.dart';
import 'package:mobile_development_iot/screens/alarms_screen.dart';
import 'package:mobile_development_iot/screens/analytics_screen.dart';
import 'package:mobile_development_iot/screens/control_screen.dart';
import 'package:mobile_development_iot/screens/home_screen.dart';
import 'package:mobile_development_iot/screens/login_screen.dart';
import 'package:mobile_development_iot/screens/profile_screen.dart';
import 'package:mobile_development_iot/screens/register_screen.dart';
import 'package:mobile_development_iot/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; 

  runApp(SmartFluidApp(isLoggedIn: isLoggedIn));
}

class SmartFluidApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const SmartFluidApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Fluid Management',
      theme: AppTheme.darkTheme,
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/control': (context) => const ControlScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/alarms': (context) => const AlarmsScreen(),
      },
    );
  }
}
