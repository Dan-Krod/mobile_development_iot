import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/auth_cubit.dart';
import 'package:mobile_development_iot/cubits/connectivity_cubit.dart';
import 'package:mobile_development_iot/utils/validators.dart';
import 'package:mobile_development_iot/widgets/common/action_button.dart';
import 'package:mobile_development_iot/widgets/common/custom_input.dart';
import 'package:mobile_development_iot/widgets/hud/fluid_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passController.text,
      );
    }
  }

  void _showOfflineError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ ACTION BLOCKED: NO INTERNET CONNECTION'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline =
        context.watch<ConnectivityCubit>().state is ConnectivityOnline;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (!ModalRoute.of(context)!.isCurrent) return;
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ ACCESS GRANTED. WELCOME BACK.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ INVALID OPERATOR ID OR SECURITY KEY'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const FluidLogo(size: 120),
                    const SizedBox(height: 30),

                    Text(
                      'SMART FLUID',
                      style: theme.appBarTheme.titleTextStyle?.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'MANAGEMENT SYSTEM',
                      style: TextStyle(
                        color: theme.primaryColor.withValues(alpha: 0.7),
                        letterSpacing: 4,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CustomInput(
                      label: 'OPERATOR EMAIL',
                      controller: _emailController,
                      icon: Icons.badge_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 15),
                    CustomInput(
                      label: 'SECURITY KEY',
                      controller: _passController,
                      icon: Icons.key_rounded,
                      isPassword: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter key' : null,
                    ),
                    const SizedBox(height: 30),
                    ActionButton(
                      text: isOnline ? 'AUTHENTICATE' : 'NO CONNECTION',
                      onPressed: isOnline ? _handleLogin : _showOfflineError,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: isOnline
                          ? () => Navigator.pushNamed(context, '/register')
                          : _showOfflineError,
                      child: RichText(
                        text: TextSpan(
                          text: 'New Engineer? ',
                          style: const TextStyle(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: 'REGISTER',
                              style: TextStyle(
                                color: isOnline
                                    ? theme.primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
