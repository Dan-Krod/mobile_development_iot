import 'package:flutter/material.dart';

class EmergencyOverrideBanner extends StatelessWidget {
  const EmergencyOverrideBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.deepOrangeAccent,
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
          SizedBox(width: 8),
          Text(
            'EMERGENCY HARDWARE OVERRIDE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
        ],
      ),
    );
  }
}

class GlowingDivider extends StatelessWidget {
  final Color color;

  const GlowingDivider({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
