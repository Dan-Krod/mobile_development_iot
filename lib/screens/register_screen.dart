import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/utils/validators.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/custom_input.dart';
import 'package:mobile_development_iot/widgets/fluid_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _hardwareController = TextEditingController(
    text: 'ESP32-S3',
  ); 
  final _dbController = TextEditingController(text: 'Shared Preferences');

  final IAuthRepository _authRepository = SharedPrefsAuthRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _hardwareController.dispose();
    _dbController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {

      final newUser = UserModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        hardware: _hardwareController.text.trim(), 
        database: _dbController.text.trim(),
      );

      await _authRepository.registerUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ENGINEER REGISTERED SUCCESSFULLY'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white70),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Form(
        key: _formKey,
        child: SizedBox(
          height: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const FluidLogo(size: 70),
                  const SizedBox(height: 35),

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

                  const SizedBox(height: 25),

                  CustomInput(
                    label: 'FULL NAME',
                    controller: _nameController,
                    icon: Icons.assignment_ind_outlined,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    label: 'ENGINEER EMAIL',
                    controller: _emailController,
                    icon: Icons.alternate_email_rounded,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    label: 'ACCESS KEY',
                    controller: _passController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    label: 'CORE HARDWARE',
                    controller: _hardwareController,
                    icon: Icons.developer_board_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Specify hardware' : null,
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    label: 'DATABASE SYSTEM',
                    controller: _dbController,
                    icon: Icons.storage_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Specify database' : null,
                  ),
                  const SizedBox(height: 30),

                  ActionButton(
                    text: 'CREATE ACCOUNT',
                    onPressed: _handleRegister,
                  ),

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
      ),
    );
  }
}
