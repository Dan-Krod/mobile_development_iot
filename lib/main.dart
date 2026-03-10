import 'package:flutter/material.dart';
import 'package:mobile_development_iot/screens/alarms_screen.dart';
import 'package:mobile_development_iot/screens/analytics_screen.dart';
import 'package:mobile_development_iot/screens/control_screen.dart';
import 'package:mobile_development_iot/screens/home_screen.dart';
import 'package:mobile_development_iot/screens/login_screen.dart';
import 'package:mobile_development_iot/screens/profile_screen.dart';
import 'package:mobile_development_iot/screens/register_screen.dart';
import 'package:mobile_development_iot/theme/app_theme.dart';

void main() {
  runApp(const SmartFluidApp());
}

class SmartFluidApp extends StatelessWidget {
  const SmartFluidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Fluid Management',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
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
