import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/alarm_item.dart';
import 'package:mobile_development_iot/widgets/tech_grid.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYSTEM ALARMS'), centerTitle: true),
      body: Stack(
        children: [
          const TechGrid(),
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'ACTIVE LOG ENTRIES',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              const AlarmItem(
                time: '17:56:12',
                message: 'Warning! Critical water level!',
                isCritical: true,
              ),
              const AlarmItem(
                time: '18:04:05',
                message: 'Warning! Pump overheated! STOP IT!',
                isCritical: true,
              ),
              const AlarmItem(
                time: '19:12:44',
                message: 'System manually disabled by operator',
              ),
              const AlarmItem(
                time: '19:15:30',
                message: 'Safety Override: Local button OFF',
              ),

              const SizedBox(height: 30),

              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.playlist_add_check_rounded,
                  size: 18,
                  color: Colors.white24,
                ),
                label: const Text(
                  'ACKNOWLEDGE ALL',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
