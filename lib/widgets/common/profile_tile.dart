import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A3FF), size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white54,
          letterSpacing: 1,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
    );
  }
}
