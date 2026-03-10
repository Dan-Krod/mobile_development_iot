import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/custom_input.dart';
import 'package:mobile_development_iot/widgets/fluid_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      body: SizedBox(
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
                    label: 'OPERATOR ID',
                    controller: emailController,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 15),
                  CustomInput(
                    label: 'SECURITY KEY',
                    controller: passController,
                    icon: Icons.key_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  ActionButton(
                    text: 'AUTHENTICATE',
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                  ),

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
