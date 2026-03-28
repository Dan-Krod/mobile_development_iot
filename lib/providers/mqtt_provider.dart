import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<void> connect(String brokerIp) async {
    if (isConnected && client != null) return;

    client = MqttServerClient(
      brokerIp,
      'lpnu_operator_${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = 1883;
    client!.keepAlivePeriod = 20;

    client!.onDisconnected = () {
      isConnected = false;
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

      notifyListeners();
    } catch (e) {
      debugPrint('🚨 MQTT Помилка підключення: $e');
      isConnected = false;
      client?.disconnect();
      notifyListeners();
    }
  }

  void disconnect() {
    client?.disconnect();
    isConnected = false;
    notifyListeners();
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
}
