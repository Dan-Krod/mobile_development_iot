import 'dart:convert';

import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAlarmRepository {
  Future<List<AlarmModel>> getAlarmsByTank(String tankId);
  Future<void> clearAlarms(String tankId);
  Future<void> addAlarm(AlarmModel alarm);
}

class SharedPrefsAlarmRepository implements IAlarmRepository {
  static const String _storageKey = 'system_alarms';

  @override
  Future<List<AlarmModel>> getAlarmsByTank(String tankId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => AlarmModel.fromJson(item as Map<String, dynamic>))
        .where((alarm) => alarm.tankId == tankId)
        .toList();
  }

  @override
  Future<void> clearAlarms(String tankId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return;

    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    final updated = decoded
        .map((item) => AlarmModel.fromJson(item as Map<String, dynamic>))
        .where((alarm) => alarm.tankId != tankId)
        .map((a) => a.toJson())
        .toList();

    await prefs.setString(_storageKey, jsonEncode(updated));
  }

  @override
  Future<void> addAlarm(AlarmModel alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    final List<dynamic> current = data != null
        ? jsonDecode(data) as List<dynamic>
        : [];
    current.add(alarm.toJson());
    await prefs.setString(_storageKey, jsonEncode(current));
  }
}
