import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/auth_cubit.dart';
import 'package:mobile_development_iot/models/user_model.dart';

class EditProfileDialog extends StatefulWidget {
  final UserModel currentUser;
  const EditProfileDialog({required this.currentUser, super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController hardwareController;
  late final TextEditingController dbController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentUser.fullName);
    hardwareController = TextEditingController(
      text: widget.currentUser.hardware,
    );
    dbController = TextEditingController(text: widget.currentUser.database);
  }

  @override
  void dispose() {
    nameController.dispose();
    hardwareController.dispose();
    dbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      title: const Text(
        'EDIT ENGINEER PROFILE',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameController, 'FULL NAME'),
            const SizedBox(height: 15),
            _buildDialogField(hardwareController, 'CORE HARDWARE'),
            const SizedBox(height: 15),
            _buildDialogField(dbController, 'DATABASE SYSTEM'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            final updatedUser = UserModel(
              fullName: nameController.text.trim(),
              email: widget.currentUser.email,
              password: widget.currentUser.password,
              hardware: hardwareController.text.trim(),
              database: dbController.text.trim(),
            );
            context.read<AuthCubit>().updateProfile(
              updatedUser,
            ); // 🚨 Виклик через Cubit
            Navigator.pop(context);
          },
          child: const Text(
            'SAVE CHANGES',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
      ),
    );
  }
}
