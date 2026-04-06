import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';

class TankWrapper extends StatelessWidget {
  final TankModel tank;

  const TankWrapper({required this.tank, super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(tank.colorValue);

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
          _buildMainBtn(context, primaryColor),
          _navIcon(context, Icons.notifications_none_rounded, '/alarms'),
        ],
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route, arguments: tank),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white24, size: 26),
      ),
    );
  }

  Widget _buildMainBtn(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/home'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.grid_view_rounded, color: primaryColor, size: 24),
      ),
    );
  }
}
