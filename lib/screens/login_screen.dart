import 'package:flutter/material.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/utils/validators.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/custom_input.dart';
import 'package:mobile_development_iot/widgets/fluid_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final IAuthRepository _authRepository = SharedPrefsAuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final bool success = await _authRepository.login(
        _emailController.text.trim(),
        _passController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ACCESS GRANTED. WELCOME BACK.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ INVALID OPERATOR ID OR SECURITY KEY'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Form(
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

                  ActionButton(text: 'AUTHENTICATE', onPressed: _handleLogin),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: TextSpan(
                        text: 'New Engineer? ',
                        style: const TextStyle(color: Colors.white54),
                        children: [
                          TextSpan(
                            text: 'REGISTER',
                            style: TextStyle(
                              color: theme.primaryColor,
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
    );
  }
}
