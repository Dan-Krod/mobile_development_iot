import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';

abstract class IAlarmRepository {
  Future<List<AlarmModel>> getAlarmsByTank(String tankId);
  Future<void> clearAlarms(String tankId);
  Future<void> addAlarm(AlarmModel alarm);
}

class SecureAlarmRepository implements IAlarmRepository {
  static const String _storageKey = 'system_alarms';
  final _storage = const FlutterSecureStorage();

  @override
  Future<List<AlarmModel>> getAlarmsByTank(String tankId) async {
    final String? data = await _storage.read(key: _storageKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => AlarmModel.fromJson(item as Map<String, dynamic>))
        .where((alarm) => alarm.tankId == tankId)
        .toList();
  }

  @override
  Future<void> clearAlarms(String tankId) async {
    final String? data = await _storage.read(key: _storageKey);
    if (data == null) return;

    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    final updated = decoded
        .map((item) => AlarmModel.fromJson(item as Map<String, dynamic>))
        .where((alarm) => alarm.tankId != tankId)
        .map((a) => a.toJson())
        .toList();

    await _storage.write(key: _storageKey, value: jsonEncode(updated));
  }

  @override
  Future<void> addAlarm(AlarmModel alarm) async {
    final String? data = await _storage.read(key: _storageKey);
    final List<dynamic> current = data != null
        ? jsonDecode(data) as List<dynamic>
        : [];

    current.add(alarm.toJson());
    await _storage.write(key: _storageKey, value: jsonEncode(current));
  }
}
