import 'package:flutter/material.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_bloc.dart';

class StatusBadge extends StatelessWidget {
  final bool isHardware;
  final MqttState state;

  const StatusBadge({required this.isHardware, required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeText;

    if (!isHardware) {
      badgeColor = Colors.purpleAccent;
      badgeText = 'VIRTUAL NODE';
    } else if (state is MqttConnecting) {
      badgeColor = Colors.orangeAccent;
      badgeText = 'CONNECTING...';
    } else if (state is MqttDataState) {
      if ((state as MqttDataState).isDeviceOnline) {
        badgeColor = Colors.greenAccent;
        badgeText = 'ESP32 CONNECTED';
      } else {
        badgeColor = Colors.orangeAccent;
        badgeText = 'BROKER OK / ESP32 OFFLINE';
      }
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
}
