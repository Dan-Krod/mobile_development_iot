import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/widgets/common/profile_tile.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel? user;

  const ProfileInfoCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          ProfileTile(
            label: 'FULL NAME',
            value: user?.fullName.toUpperCase() ?? 'NOT SET',
            icon: Icons.person_search_rounded,
          ),
          const _CustomDivider(),
          ProfileTile(
            label: 'ENGINEER EMAIL',
            value: user?.email ?? 'NOT SET',
            icon: Icons.alternate_email_rounded,
          ),
          const _CustomDivider(),
          ProfileTile(
            label: 'CORE HARDWARE',
            value: user?.hardware ?? 'UNKNOWN',
            icon: Icons.developer_board_rounded,
          ),
          const _CustomDivider(),
          ProfileTile(
            label: 'DATABASE',
            value: user?.database ?? 'UNKNOWN',
            icon: Icons.storage_rounded,
          ),
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

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
