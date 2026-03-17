import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/fluid_tank_observation.dart';
import 'package:mobile_development_iot/widgets/sensor_card.dart';
import 'package:mobile_development_iot/widgets/tank_wrapper.dart';

class TankDetailsScreen extends StatelessWidget {
  const TankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final tankColor = Color(tank.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(
          tank.title.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: ObservationBay(
              primaryColor: tankColor, 
              onTankTap: () {},
            ),
          ),

          _buildGlowingDivider(tankColor),

          _buildSensorRow(tankColor),

          TankWrapper(tank: tank),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildSensorRow(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: SensorCard(
              label: 'FLUID MASS',
              value: '334.72',
              unit: 'g',
              icon: Icons.scale,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: SensorCard(
              label: 'MOTOR TEMP',
              value: '24.57',
              unit: '°C',
              icon: Icons.thermostat,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingDivider(Color color) {
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
