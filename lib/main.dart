import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_development_iot/blocs/auth/auth_bloc.dart';
import 'package:mobile_development_iot/blocs/connectivity/connectivity_bloc.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_bloc.dart';
import 'package:mobile_development_iot/blocs/tank/tank_bloc.dart';

import 'package:mobile_development_iot/repositories/alarm_repository.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = SecureAuthRepository();
  final tankRepository = SecureTankRepository();
  final alarmRepository = SecureAlarmRepository();

  final currentUser = await authRepository.getCurrentUser();
  final bool isLoggedIn = currentUser != null;

  runApp(
    SmartFluidApp(
      isLoggedIn: isLoggedIn,
      authRepository: authRepository,
      tankRepository: tankRepository,
      alarmRepository: alarmRepository,
    ),
  );
}

class SmartFluidApp extends StatelessWidget {
  final bool isLoggedIn;
  final IAuthRepository authRepository;
  final ITankRepository tankRepository;
  final IAlarmRepository alarmRepository;

  const SmartFluidApp({
    required this.isLoggedIn,
    required this.authRepository,
    required this.tankRepository,
    required this.alarmRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>.value(value: authRepository),
        RepositoryProvider<ITankRepository>.value(value: tankRepository),
        RepositoryProvider<IAlarmRepository>.value(value: alarmRepository),
        RepositoryProvider<ApiClient>(create: (context) => ApiClient()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(context.read<IAuthRepository>())
                  ..add(LoadCurrentUserEvent()),
          ),
          BlocProvider<ConnectivityBloc>(
            create: (context) => ConnectivityBloc(),
          ),
          BlocProvider<MqttBloc>(
            create: (context) => MqttBloc(
              context.read<IAuthRepository>(),
              context.read<ApiClient>(),
            ),
          ),
          BlocProvider<TankBloc>(
            create: (context) =>
                TankBloc(context.read<ITankRepository>())
                  ..add(LoadTanksEvent()),
          ),
        ],
        child: MaterialApp(
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
        ),
      ),
    );
  }
}
