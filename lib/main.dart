import 'package:flutter/material.dart';
import 'package:mobile_development_iot/screens/login_screen.dart';
import 'package:mobile_development_iot/screens/register_screen.dart';
import 'theme/app_theme.dart';

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
        '/home': (context) => const _PlaceholderScreen(title: 'LOGIN PAGE'),
        '/profile': (context) => const _PlaceholderScreen(title: 'PROFILE'),
        '/control': (context) => const _PlaceholderScreen(title: 'CONTROL UNIT'),
        '/analytics': (context) => const _PlaceholderScreen(title: 'DATA ANALYTICS'),
        '/alarms': (context) => const _PlaceholderScreen(title: 'SYSTEM ALERTS'),
      },
    );
  }
}

// Temporary widget for unrealised screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title IN DEVELOPMENT',
          style: const TextStyle(color: Colors.white24, letterSpacing: 2),
        ),
      ),
    );
  }
}
