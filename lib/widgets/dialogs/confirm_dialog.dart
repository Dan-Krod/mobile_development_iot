import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;

  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    super.key,
    this.confirmColor = Colors.blue,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    Color confirmColor = Colors.blue,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => ConfirmDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            confirmColor: confirmColor,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
