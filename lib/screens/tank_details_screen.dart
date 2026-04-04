import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/tank/fluid_tank_observation.dart';
import 'package:mobile_development_iot/widgets/tank/sensor_card.dart';
import 'package:mobile_development_iot/widgets/tank/tank_wrapper.dart';

class TankDetailsScreen extends StatelessWidget {
  const TankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final tankColor = Color(tank.colorValue);
    final isHardware = tank.isHardwareBound;

    if (isHardware) {
      Future.microtask(() {
        if (!context.mounted) return;
        final mqtt = context.read<MqttCubit>();
        if (mqtt.state is MqttInitial || mqtt.state is MqttDisconnected) {
          mqtt.connect('10.217.121.222');
        }
      });
    }

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
            BlocBuilder<MqttCubit, MqttState>(
              builder: (context, mqttState) {
                return _buildStatusBadge(isHardware, mqttState);
              },
            ),
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
          BlocBuilder<MqttCubit, MqttState>(
            builder: (context, mqttState) {
              return _buildSensorRow(tankColor, isHardware, mqttState);
            },
          ),
          TankWrapper(tank: tank),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isHardware, MqttState state) {
    Color badgeColor;
    String badgeText;

    if (!isHardware) {
      badgeColor = Colors.purpleAccent;
      badgeText = 'VIRTUAL NODE';
    } else if (state is MqttConnecting) {
      badgeColor = Colors.orangeAccent;
      badgeText = 'CONNECTING...';
    } else if (state is MqttDataState) {
      badgeColor = Colors.greenAccent;
      badgeText = 'ESP32 CONNECTED';
    } else if (state is MqttBlocked) {
      badgeColor = Colors.red;
      badgeText = 'ACCESS DENIED';
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

  Widget _buildSensorRow(Color color, bool isHardware, MqttState state) {
    String fluidVal = '334.72';
    String fluidUnit = 'g';
    String tempVal = '24.57';
    Color tempColor = Colors.orangeAccent;

    if (isHardware && state is MqttDataState) {
      fluidVal = state.level.toStringAsFixed(1);
      fluidUnit = '%';
      tempVal = state.temp.toStringAsFixed(1);
      if (state.temp > 40) tempColor = Colors.redAccent;
    }

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
              color: tempColor,
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
