import 'package:flutter/material.dart';

class MainWrapper extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onAddPressed;

  const MainWrapper({required this.primaryColor, super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: onAddPressed,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white54,
            ),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}
