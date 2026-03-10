import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: color != null 
          ? ElevatedButton.styleFrom(backgroundColor: color) 
          : null,
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            letterSpacing: 2, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
