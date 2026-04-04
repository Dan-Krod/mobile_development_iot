import 'package:flutter/material.dart';
import 'package:mobile_development_iot/providers/auth_provider.dart';
import 'package:mobile_development_iot/providers/connectivity_provider.dart';
import 'package:mobile_development_iot/providers/mqtt_provider.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/screens/alarms_screen.dart';
import 'package:mobile_development_iot/screens/analytics_screen.dart';
import 'package:mobile_development_iot/screens/control_screen.dart';
import 'package:mobile_development_iot/screens/home_screen.dart';
import 'package:mobile_development_iot/screens/login_screen.dart';
import 'package:mobile_development_iot/screens/profile_screen.dart';
import 'package:mobile_development_iot/screens/register_screen.dart';
import 'package:mobile_development_iot/screens/tank_details_screen.dart';
import 'package:mobile_development_iot/theme/app_theme.dart';
import 'package:mobile_development_iot/widgets/layout/connectivity_overlay.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = SecureAuthRepository();

  final currentUser = await authRepository.getCurrentUser();
  final bool isLoggedIn = currentUser != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final auth = AuthProvider(authRepository);
            if (isLoggedIn) auth.loadSession();
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (_) => MqttProvider()),
      ],
      child: SmartFluidApp(isLoggedIn: isLoggedIn),
    ),
  );
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

      builder: (context, child) {
        return ConnectivityOverlay(child: child!);
      },

      initialRoute: isLoggedIn ? '/home' : '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/details': (context) => const TankDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/control': (context) => const ControlScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/alarms': (context) => const AlarmsScreen(),
      },
    );
  }
}
