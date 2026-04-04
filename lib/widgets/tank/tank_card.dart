import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_development_iot/cubits/tank_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';

class TankCard extends StatelessWidget {
  final TankModel tank;
  const TankCard({required this.tank, super.key});

  @override
  Widget build(BuildContext context) {
    final mqttState = context.watch<MqttCubit>().state;
    final isHardware = tank.isHardwareBound;
    final color = Color(tank.colorValue);

    return Stack(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/details', arguments: tank),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeBadge(isHardware, color),
                _buildTankInfo(mqttState, isHardware, color),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: color, size: 18),
            onPressed: () => context.read<TankCubit>().deleteTank(tank.id),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(bool isHardware, Color color) {
    return Row(
      children: [
        Icon(
          isHardware ? Icons.memory : Icons.hub_outlined,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isHardware
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isHardware ? 'ESP32' : 'VIRTUAL',
            style: TextStyle(
              color: isHardware ? Colors.green : Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTankInfo(MqttState mqttState, bool isHardware, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tank.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(tank.currentLevel * 100).toInt()}% LOADED',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (isHardware && mqttState is MqttDataState)
              Text(
                '${mqttState.temp.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
