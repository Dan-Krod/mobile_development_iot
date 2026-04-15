import 'package:flutter/material.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_bloc.dart';
import 'package:mobile_development_iot/widgets/tank/sensor_card.dart';

class TankSensorRow extends StatelessWidget {
  final Color color;
  final bool isHardware;
  final MqttState state;

  const TankSensorRow({
    required this.color,
    required this.isHardware,
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String fluidVal = '334.72';
    String fluidUnit = 'g';
    String tempVal = '24.57';
    Color tempColor = Colors.orangeAccent;

    if (isHardware && state is MqttDataState) {
      final dataState = state as MqttDataState;
      fluidVal = dataState.level.toStringAsFixed(1);
      fluidUnit = '%';
      tempVal = dataState.temp.toStringAsFixed(1);
      if (dataState.temp > 40) tempColor = Colors.redAccent;
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
}
