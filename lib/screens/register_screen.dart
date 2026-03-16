import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/custom_input.dart';
import 'package:mobile_development_iot/widgets/fluid_logo.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white70),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              children: [
                const FluidLogo(size: 80),
                const SizedBox(height: 25),

                Text(
                  'ENGINEER ENROLLMENT',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NEW SYSTEM NODE ACCESS',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                CustomInput(
                  label: 'FULL NAME',
                  controller: nameController,
                  icon: Icons.assignment_ind_outlined,
                ),
                const SizedBox(height: 15),
                CustomInput(
                  label: 'ENGINEER EMAIL',
                  controller: emailController,
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 15),
                CustomInput(
                  label: 'ACCESS KEY',
                  controller: passController,
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 15),
                CustomInput(
                  label: 'CONFIRM KEY',
                  controller: confirmController,
                  icon: Icons.security_rounded,
                  isPassword: true,
                ),

                const SizedBox(height: 40),

                ActionButton(
                  text: 'CREATE ACCOUNT',
                  onPressed: () => Navigator.pushNamed(context, '/'),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ALREADY HAVE ACCESS? SIGN IN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
