import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/fluid_tank_observation.dart';
import 'package:mobile_development_iot/widgets/sensor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF38BDF8);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'SMART FLUID SYSTEM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: ObservationBay(
              primaryColor: primaryColor,
              onTankTap: () => _showDiagnostics(context),
            ),
          ),

          _buildGlowingDivider(primaryColor),

          _buildSensorRow(),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildSensorRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: SensorCard(
              label: 'FLUID MASS',
              value: '334.72',
              unit: 'g',
              icon: Icons.scale,
              color: Color(0xFF38BDF8),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
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

  void _showDiagnostics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SYSTEM DIAGNOSTICS: NOMINAL'),
        backgroundColor: Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
