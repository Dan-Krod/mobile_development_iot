import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';

class AlarmHelper {
  static Future<void> triggerImpactAlarm(
    BuildContext context,
    TankModel tank,
  ) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🛑 SYSTEM HALT: ${tank.title.toUpperCase()} IMPACT'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    final alarmRepo = SecureAlarmRepository();
    final now = DateTime.now();
    final shockAlarm = AlarmModel(
      id: now.millisecondsSinceEpoch.toString(),
      tankId: tank.id,
      message: 'CRITICAL: PHYSICAL IMPACT DETECTED',
      time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      isCritical: true,
    );

    try {
      await alarmRepo.addAlarm(shockAlarm);
    } catch (e) {
      debugPrint('[ERROR] Could not save alarm: $e');
    }
  }
}
