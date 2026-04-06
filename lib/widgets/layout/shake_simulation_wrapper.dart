import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';
import 'package:shake/shake.dart';

class ShakeSimulationWrapper extends StatefulWidget {
  final Widget child;
  final List<TankModel> tanks;
  final VoidCallback? onShockSimulated;

  const ShakeSimulationWrapper({
    required this.child,
    required this.tanks,
    this.onShockSimulated,
    super.key,
  });

  @override
  State<ShakeSimulationWrapper> createState() => _ShakeSimulationWrapperState();
}

class _ShakeSimulationWrapperState extends State<ShakeSimulationWrapper> {
  late ShakeDetector detector;
  final IAlarmRepository _alarmRepository = SecureAlarmRepository();
  Color _debugColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    developer.log('[SYSTEM] ShakeDetector Initializing...');

    detector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      onPhoneShake: (_) {
        developer.log('\n[SENSOR] SHAKE GESTURE DETECTED!');

        if (mounted) {
          setState(() => _debugColor = Colors.red.withValues(alpha: 0.3));

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚡ SENSOR: CRITICAL IMPACT DETECTED!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _debugColor = Colors.transparent);
          });
        }

        _simulateSystemShock();
      },
    );
  }

  Future<void> _simulateSystemShock() async {
    developer.log('[LOGIC] Starting alarm creation...');
    developer.log('[DATA] Available tanks: ${widget.tanks.length}');

    if (widget.tanks.isEmpty) {
      developer.log('[ABORT] No tanks in list. Create a tank node first!');
      return;
    }

    final targetTank = widget.tanks.first;
    developer.log('[TARGET] Creating alarm for node: ${targetTank.title}');

    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');

    final shockAlarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tankId: targetTank.id,
      message: 'CRITICAL: PHYSICAL IMPACT DETECTED',
      time: '$hour:$minute',
      isCritical: true,
    );

    try {
      await _alarmRepository.addAlarm(shockAlarm);
      developer.log('✅ [SUCCESS] Alarm saved to SharedPrefs!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🛑 SYSTEM HALT: ${targetTank.title.toUpperCase()} IMPACT',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      widget.onShockSimulated?.call();
    } catch (e) {
      developer.log('[ERROR] Could not save alarm: $e');
    }
  }

  @override
  void dispose() {
    developer.log('[SYSTEM] ShakeDetector Disposed');
    detector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _debugColor,
      child: widget.child,
    );
  }
}
