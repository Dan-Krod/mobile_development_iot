import 'package:flutter/material.dart';
import 'package:mobile_development_iot/screens/audit_logs_screen.dart';

class AuditLogsTile extends StatelessWidget {
  const AuditLogsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.list_alt_rounded, color: Colors.blueAccent),
      title: const Text(
        'VIEW AUDIT LOGS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white10),
        borderRadius: BorderRadius.circular(16),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => const AuditLogsScreen(),
          ),
        );
      },
    );
  }
}
