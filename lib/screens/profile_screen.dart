import 'package:flutter/material.dart';
import 'package:mobile_development_iot/services/auth_service.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/profile_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            onPressed: () {},
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
                child: const Column(
                  children: [
                    ProfileTile(
                      label: 'FULL NAME',
                      value: 'MR ROBOT',
                      icon: Icons.person_search_rounded,
                    ),
                    _Divider(),
                    ProfileTile(
                      label: 'CORE HARDWARE',
                      value: 'ESP32-S3',
                      icon: Icons.developer_board_rounded,
                    ),
                    _Divider(),
                    ProfileTile(
                      label: 'NETWORK LAYER',
                      value: 'MQTT over Sparkplug B',
                      icon: Icons.wifi_tethering_rounded,
                    ),
                    _Divider(),
                    ProfileTile(
                      label: 'DATABASE',
                      value: 'MySQL',
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
                  onPressed: () async {
                    await AuthService.logout();

                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (r) => false, 
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'v2.0.4 - SECURE NODE CONNECTION',
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
