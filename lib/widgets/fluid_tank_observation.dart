import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/fluid_tank.dart';
import 'package:mobile_development_iot/widgets/hud_brackets.dart';
import 'package:mobile_development_iot/widgets/hud_corner.dart';

class ObservationBay extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onTankTap;

  const ObservationBay({
    required this.primaryColor,
    required this.onTankTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Stack(
        children: [
          _buildBlueprint(),
          const HUDBrackets(color: Colors.white24),
          Center(
            child: GestureDetector(
              onTap: onTankTap,
              child: const FluidTank(level: 0.31),
            ),
          ),
          HUDCorner(
            top: 25,
            left: 25,
            title: 'NODE STATUS',
            value: 'S3-ACTIVE',
            color: primaryColor,
            hasPulse: true,
          ),
          const HUDCorner(
            top: 25,
            right: 25,
            title: 'OPERATOR',
            value: 'MR ROBOT',
            color: Colors.white70,
          ),
          HUDCorner(
            bottom: 25,
            left: 25,
            title: 'MQTT LINK',
            value: 'STABLE',
            color: primaryColor,
          ),
          const HUDCorner(
            bottom: 25,
            right: 25,
            title: 'SOLENOID',
            value: 'CLOSED',
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprint() {
    return Opacity(
      opacity: 0.04,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GridPaper(color: primaryColor, divisions: 1, subdivisions: 4),
      ),
    );
  }
}
