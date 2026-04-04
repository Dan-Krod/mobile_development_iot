import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/providers/mqtt_provider.dart';
import 'package:mobile_development_iot/widgets/tank/fluid_tank_observation.dart';
import 'package:mobile_development_iot/widgets/tank/sensor_card.dart';
import 'package:mobile_development_iot/widgets/tank/tank_wrapper.dart';
import 'package:provider/provider.dart';

class TankDetailsScreen extends StatefulWidget {
  const TankDetailsScreen({super.key});

  @override
  State<TankDetailsScreen> createState() => _TankDetailsScreenState();
}

class _TankDetailsScreenState extends State<TankDetailsScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
      if (tank.isHardwareBound) {
        context.read<MqttProvider>().connect('10.217.121.222');
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final tankColor = Color(tank.colorValue);
    final isHardware = tank.isHardwareBound;

    final mqtt = context.watch<MqttProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              tank.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusBadge(isHardware, mqtt.isConnected),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: ObservationBay(primaryColor: tankColor, onTankTap: () {}),
          ),

          _buildGlowingDivider(tankColor),

          _buildSensorRow(tankColor, isHardware, mqtt),

          TankWrapper(tank: tank),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isHardware, bool isMqttConnected) {
    Color badgeColor;
    String badgeText;

    if (!isHardware) {
      badgeColor = Colors.purpleAccent;
      badgeText = 'VIRTUAL NODE';
    } else if (isMqttConnected) {
      badgeColor = Colors.greenAccent;
      badgeText = 'ESP32 CONNECTED';
    } else {
      badgeColor = Colors.redAccent;
      badgeText = 'ESP32 DISCONNECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSensorRow(Color color, bool isHardware, MqttProvider mqtt) {
    final fluidVal = isHardware ? mqtt.level.toStringAsFixed(1) : '334.72';
    final fluidUnit = isHardware ? '%' : 'g';

    final tempVal = isHardware ? mqtt.temp.toStringAsFixed(1) : '24.57';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: SensorCard(
              label: isHardware ? 'FLUID LEVEL' : 'FLUID MASS',
              value: fluidVal,
              unit: fluidUnit,
              icon: Icons.waves,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SensorCard(
              label: 'MOTOR TEMP',
              value: tempVal,
              unit: '°C',
              icon: Icons.thermostat,
              color: isHardware && mqtt.temp > 40
                  ? Colors.redAccent
                  : Colors.orangeAccent,
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
