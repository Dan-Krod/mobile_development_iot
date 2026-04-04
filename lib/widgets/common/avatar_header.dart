import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/dialogs/admin_override_dialog.dart';

class AvatarHeader extends StatelessWidget {
  const AvatarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onLongPress: () => showDialog<void>(
            context: context,
            builder: (_) => const AdminOverrideDialog(),
          ),
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
