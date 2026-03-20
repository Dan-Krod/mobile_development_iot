import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/profile_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final IAuthRepository _authRepository = SharedPrefsAuthRepository();

  UserModel? _currentUser;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authRepository.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _editProfile() async {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser!.fullName);
    final hardwareController = TextEditingController(
      text: _currentUser!.hardware,
    );
    final dbController = TextEditingController(text: _currentUser!.database);

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
                email: _currentUser!.email,
                password: _currentUser!.password,
                hardware: hardwareController.text.trim(),
                database: dbController.text.trim(),
              );

              await _authRepository.registerUser(updatedUser);
              if (mounted) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadUserData();
              }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENGINEER PROFILE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white54),
            onPressed: _editProfile,
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
              _buildAvatarHeader(theme),
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
                      value: _currentUser?.fullName.toUpperCase() ?? 'NOT SET',
                      icon: Icons.person_search_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'ENGINEER EMAIL',
                      value: _currentUser?.email ?? 'NOT SET',
                      icon: Icons.alternate_email_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'CORE HARDWARE',
                      value: _currentUser?.hardware ?? 'UNKNOWN',
                      icon: Icons.developer_board_rounded,
                    ),
                    const _Divider(),
                    ProfileTile(
                      label: 'DATABASE',
                      value: _currentUser?.database ?? 'UNKNOWN',
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
                'v3.0.0 - REPOSITORY LAYER ACTIVE',
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
      builder: (context) => Container(
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
                await _authRepository.logout();
                if (context.mounted) _redirectToLogin(context);
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
                await _authRepository.deleteAccount();
                if (context.mounted) _redirectToLogin(context);
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

  Widget _buildAvatarHeader(ThemeData theme) {
    return Column(
      children: [
        Stack(
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
