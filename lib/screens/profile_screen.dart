import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/providers/auth_provider.dart';
import 'package:mobile_development_iot/providers/mqtt_provider.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/profile_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editProfile(UserModel currentUser) async {
    final nameController = TextEditingController(text: currentUser.fullName);
    final hardwareController = TextEditingController(
      text: currentUser.hardware,
    );
    final dbController = TextEditingController(text: currentUser.database);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'EDIT ENGINEER PROFILE',
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2),
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
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = UserModel(
                fullName: nameController.text.trim(),
                email: currentUser.email,
                password: currentUser.password,
                hardware: hardwareController.text.trim(),
                database: dbController.text.trim(),
              );

              await context.read<AuthProvider>().register(updatedUser);

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text(
              'SAVE CHANGES',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdminOverrideDialog(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final mqttProvider = context.read<MqttProvider>();

    double startH = authProvider.shiftStartHour.toDouble();
    double endH = authProvider.shiftEndHour.toDouble();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'ADMIN OVERRIDE',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CONFIGURE OPERATIONAL WINDOW',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'SYSTEM BOOT: ${startH.toInt()}:00',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: startH,
                max: 23,
                divisions: 23,
                activeColor: Colors.blueAccent,
                onChanged: (val) {
                  if (val < endH) setState(() => startH = val);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'SYSTEM HALT: ${endH.toInt()}:00',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: endH,
                min: 1,
                max: 24,
                divisions: 23,
                activeColor: Colors.redAccent,
                onChanged: (val) {
                  if (val > startH) setState(() => endH = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () {
                authProvider.saveOperationalHours(startH.toInt(), endH.toInt());
                mqttProvider.setOperationalHours(startH.toInt(), endH.toInt());
                Navigator.pop(context);
              },
              child: const Text(
                'ENGAGE PROTOCOL',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    Color confirmColor = Colors.blue,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color: confirmColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENGINEER PROFILE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white54),
              onPressed: () => _editProfile(user),
            ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              _buildAvatarHeader(context, theme),
              const SizedBox(height: 30),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color!.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    ProfileTile(
                      label: 'FULL NAME',
                      value: user?.fullName.toUpperCase() ?? 'NOT SET',
                      icon: Icons.person_search_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'ENGINEER EMAIL',
                      value: user?.email ?? 'NOT SET',
                      icon: Icons.alternate_email_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'CORE HARDWARE',
                      value: user?.hardware ?? 'UNKNOWN',
                      icon: Icons.developer_board_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'DATABASE',
                      value: user?.database ?? 'UNKNOWN',
                      icon: Icons.storage_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActionButton(
                  text: 'TERMINATE SESSION',
                  onPressed: () => _showExitOptions(context),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'v4.0.0 - PROVIDER LAYER ACTIVE',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) => Container(
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
              title: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Close session, keep local data',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext);

                final confirmed = await _showConfirmDialog(
                  title: 'CONFIRM LOGOUT',
                  message:
                      'Are you sure you want to terminate '
                      'your current session?',
                  confirmText: 'LOGOUT',
                );

                if (confirmed) {
                  if (!context.mounted) return;
                  await context.read<AuthProvider>().logout();

                  if (!context.mounted) return;
                  _redirectToLogin(context);
                }
              },
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
              onTap: () async {
                Navigator.pop(bottomSheetContext);

                final confirmed = await _showConfirmDialog(
                  title: 'EXTREME ACTION: WIPE DATA',
                  message:
                      'This will permanently delete your account and '
                      'all associated IoT nodes. Proceed?',
                  confirmText: 'DELETE EVERYTHING',
                  confirmColor: Colors.redAccent,
                );

                if (confirmed) {
                  if (!context.mounted) return;
                  await context.read<AuthProvider>().deleteAccount();

                  if (!context.mounted) return;
                  _redirectToLogin(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _redirectToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  Widget _buildAvatarHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () => _showAdminOverrideDialog(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.cardTheme.color,
                child: Icon(
                  Icons.engineering_rounded,
                  size: 50,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'OPERATOR #3-SCA',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'LPNU',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}
