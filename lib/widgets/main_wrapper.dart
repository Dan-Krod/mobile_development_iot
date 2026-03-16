import 'package:flutter/material.dart';

class MainWrapper extends StatelessWidget {
  final Color primaryColor;

  const MainWrapper({required this.primaryColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(context, Icons.analytics_outlined, '/analytics'),
          _navIcon(context, Icons.tune_rounded, '/control'),
          _buildMainBtn(),
          _navIcon(context, Icons.notifications_none_rounded, '/alarms'),
          _navIcon(context, Icons.person_outline_rounded, '/profile'),
        ],
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white24, size: 26),
      ),
    );
  }

  Widget _buildMainBtn() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Icon(Icons.grid_view_rounded, color: primaryColor, size: 24),
    );
  }
}
