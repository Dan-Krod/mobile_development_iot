import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/auth_cubit.dart';
import 'package:mobile_development_iot/widgets/dialogs/confirm_dialog.dart';

enum ExitAction { logout, delete }

class ExitOptionsSheet extends StatelessWidget {
  const ExitOptionsSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final action = await showModalBottomSheet<ExitAction>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => const ExitOptionsSheet(),
    );

    if (action == null || !context.mounted) return;

    if (action == ExitAction.logout) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'CONFIRM LOGOUT',
        message: 'Are you sure you want to terminate your current session?',
        confirmText: 'LOGOUT',
      );
      if (confirmed && context.mounted) {
        context.read<AuthCubit>().logout();
      }
    } else if (action == ExitAction.delete) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'EXTREME ACTION: WIPE DATA',
        message:
            'This will permanently delete your account and all associated'
            'IoT nodes. Proceed?',
        confirmText: 'DELETE EVERYTHING',
        confirmColor: Colors.redAccent,
      );
      if (confirmed && context.mounted) {
        context.read<AuthCubit>().deleteAccount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SELECT TERMINATION TYPE',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.blue),
            title: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Close session, keep local data',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
            onTap: () => Navigator.pop(context, ExitAction.logout),
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.redAccent,
            ),
            title: const Text(
              'DELETE ACCOUNT',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Wipe all engineer data and nodes',
              style: TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
            onTap: () => Navigator.pop(context, ExitAction.delete),
          ),
        ],
      ),
    );
  }
}
