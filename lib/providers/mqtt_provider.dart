import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttProvider extends ChangeNotifier {
  MqttServerClient? client;

  double temp = 0;
  double level = 0;
  bool pumpStatus = false;
  bool localOverride = false;
  bool systemActive = false;
  bool isConnected = false;

  int startHour = 10;
  int endHour = 22;
  Timer? _timeGuardTimer;

  final _storage = const FlutterSecureStorage();
  final _api = ApiClient();

  bool get isOperationalTime {
    final now = DateTime.now();
    return now.hour >= startHour && now.hour < endHour;
  }

  Future<String> _getCurrentUserEmail() async {
    try {
      final userStr = await _storage.read(key: 'registered_user');
      if (userStr != null) {
        final Map<String, dynamic> userData =
            jsonDecode(userStr) as Map<String, dynamic>;
        return (userData['email'] as String?) ?? 'unknown_operator';
      }
    } catch (e) {
      debugPrint('Помилка читання email: $e');
    }
    return 'system_override'; 
  }

  void setOperationalHours(int start, int end) {
    startHour = start;
    endHour = end;
    notifyListeners();

    if (!isOperationalTime && isConnected) {
      debugPrint('[TIME GUARD] Графік змінено. Негайне відключення!');
      disconnect();
    }
  }

  Future<void> connect(String brokerIp) async {
    if (!isOperationalTime) {
      debugPrint(
        '[ACCESS DENIED] Поза робочими годинами ($startHour:00 - $endHour:00)',
      );
      final email = await _getCurrentUserEmail();
      await _api.postLog(
        email,
        'BLOCKED: Connection attempt outside operational hours',
      );

      return;
    }

    if (isConnected && client != null) return;

    client = MqttServerClient(
      brokerIp,
      'lpnu_operator_${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = 1883;
    client!.keepAlivePeriod = 20;

    client!.onDisconnected = () {
      isConnected = false;
      _timeGuardTimer?.cancel();
      debugPrint('❌ MQTT Відключено від брокера');
      notifyListeners();
    };

    try {
      debugPrint('⏳ MQTT Підключення до $brokerIp...');
      await client!.connect();
      isConnected = true;
      debugPrint('✅ MQTT Підключено успішно!');

      client!.subscribe('watertank/status', MqttQos.atMostOnce);

      client!.updates!.listen((
        List<MqttReceivedMessage<MqttMessage>> messages,
      ) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        _parseEsp32Data(payload);
      });

      _startOperationGuard();

      notifyListeners();
    } catch (e) {
      debugPrint('🚨 MQTT Помилка підключення: $e');
      isConnected = false;
      client?.disconnect();
      notifyListeners();
    }
  }

  void disconnect() {
    _timeGuardTimer?.cancel();
    client?.disconnect();
    isConnected = false;
    notifyListeners();
  }

  void _startOperationGuard() {
    _timeGuardTimer?.cancel();
    _timeGuardTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!isOperationalTime && isConnected) {
        debugPrint('[TIME GUARD] Робоча зміна закінчилась. Відключення...');

        final email = await _getCurrentUserEmail();
        await _api.postLog(
          email,
          'SYSTEM HALT: Auto-disconnected at shift end',
        );

        disconnect();
      }
    });
  }

  void _parseEsp32Data(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      temp = (data['temp'] as num?)?.toDouble() ?? 0.0;
      level = (data['level'] as num?)?.toDouble() ?? 0.0;
      pumpStatus = data['pump_status'] == true;
      localOverride = data['local_override'] == true;
      systemActive = data['sys_status'] == true;

      notifyListeners();
    } catch (e) {
      debugPrint('Помилка парсингу JSON з ESP32: $e');
    }
  }

  void sendCommand(String key, bool value) {
    if (!isConnected || localOverride) {
      debugPrint(
        '⚠️ Команду заблоковано: '
        '${localOverride ? "LOCAL OVERRIDE ACTIVE" : "DISCONNECTED"}',
      );
      return;
    }

    if (key == 'system_status') {
      systemActive = value;
    } else if (key == 'pump_command') {
      pumpStatus = value;
    }
    notifyListeners();

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode({key: value}));

    client!.publishMessage(
      'watertank/commands',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    debugPrint('📤 MQTT Відправлено: {$key: $value}');
  }

  @override
  void dispose() {
    _timeGuardTimer?.cancel();
    super.dispose();
  }
}
