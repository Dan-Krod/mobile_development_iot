import 'package:flutter/material.dart';

class UnsupportedOsDialog extends StatelessWidget {
  const UnsupportedOsDialog({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const UnsupportedOsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            'UNSUPPORTED OS',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: const Text(
        'Emergency override protocol (Flashlight)'
        'is strictly limited to Android hardware nodes.',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'ACKNOWLEDGE',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}
