import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_state.dart';

class MqttCubit extends Cubit<MqttState> {
  final IAuthRepository _authRepo;
  final ApiClient _apiClient;

  MqttServerClient? _client;
  Timer? _timeGuardTimer;

  int shiftStartHour = 10;
  int shiftEndHour = 22;

  MqttCubit(this._authRepo, this._apiClient) : super(MqttInitial()) {
    _loadOperationalHours();
  }

  bool get _isOperationalTime {
    final now = DateTime.now();
    return now.hour >= shiftStartHour && now.hour < shiftEndHour;
  }

  Future<void> _loadOperationalHours() async {
    final hours = await _authRepo.getOperationalHours();
    shiftStartHour = hours['start'] ?? 10;
    shiftEndHour = hours['end'] ?? 22;
  }

  Future<void> _logAction(String action) async {
    try {
      final user = await _authRepo.getCurrentUser();
      final email = user?.email ?? 'unknown_operator';
      await _apiClient.postLog(email, action);
    } catch (e) {
      debugPrint('🚨 Помилка запису логу: $e');
    }
  }

  Future<void> setOperationalHours(int start, int end) async {
    debugPrint('--- [MQTT] Отримано нові години: $start:00 - $end:00 ---');
    shiftStartHour = start;
    shiftEndHour = end;

    if (!_isOperationalTime) {
      debugPrint('🔒 [TIME GUARD] Час не підходить! Блокую систему.');
      await _logAction(
        'SYSTEM BLOCKED: Shift changed to $start:00-$end:00 '
        '(Current time outside range)',
      );
      disconnect();
      emit(
        MqttBlocked(
          'ACCESS DENIED: Outside operational hours ($start:00 - $end:00)',
        ),
      );
    } else {
      debugPrint('✅ [TIME GUARD] Час підходить. Знімаю блок.');
      if (state is MqttBlocked) {
        await _logAction(
          'SYSTEM UNBLOCKED: Shift changed to $start:00-$end:00',
        );
        emit(MqttDisconnected());
      }
    }
  }

  Future<void> connect(String brokerIp) async {
    if (state is MqttConnecting ||
        state is MqttDataState ||
        state is MqttBlocked) {
      return;
    }

    if (!_isOperationalTime) {
      debugPrint('🚫 [TIME GUARD] Спроба входу в неробочий час. Блокуємо.');
      emit(
        MqttBlocked(
          'ACCESS DENIED: Outside operational hours'
          '($shiftStartHour:00 - $shiftEndHour:00)',
        ),
      );
      await _logAction('BLOCKED: Connection attempt outside operational hours');
      return;
    }

    emit(MqttConnecting());

    _client =
        MqttServerClient(
            brokerIp,
            'lpnu_op_${DateTime.now().millisecondsSinceEpoch}',
          )
          ..port = 1883
          ..keepAlivePeriod = 20
          ..connectTimeoutPeriod = 5000
          ..onDisconnected = () {
            _timeGuardTimer?.cancel();
            debugPrint('❌ MQTT Відключено');
            if (state is! MqttBlocked) emit(MqttDisconnected());
          };

    try {
      debugPrint('⏳ MQTT Підключення до $brokerIp...');
      await _client!.connect().timeout(const Duration(seconds: 6));
      emit(
        MqttDataState(
          temp: 0,
          level: 0,
          pumpStatus: false,
          localOverride: false,
          systemActive: false,
        ),
      );
      debugPrint('✅ MQTT Підключено!');

      _client!.subscribe('watertank/status', MqttQos.atMostOnce);
      _client!.updates!.listen((messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        _parseEsp32Data(
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message),
        );
      });

      _startOperationGuard();
    } catch (e) {
      debugPrint('🚨 MQTT Тайм-аут або помилка: $e');
      _client?.disconnect();
      emit(MqttDisconnected());
    }
  }

  void _parseEsp32Data(String jsonString) {
    if (state is! MqttDataState) return;
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final currentState = state as MqttDataState;
      emit(
        currentState.copyWith(
          temp: (data['temp'] as num?)?.toDouble(),
          level: (data['level'] as num?)?.toDouble(),
          pumpStatus: data['pump_status'] == true,
          localOverride: data['local_override'] == true,
          systemActive: data['sys_status'] == true,
        ),
      );
    } catch (_) {}
  }

  void sendCommand(String key, bool value) {
    if (state is! MqttDataState || _client == null) return;
    final currentState = state as MqttDataState;
    if (currentState.localOverride) return;

    if (key == 'system_status') {
      emit(currentState.copyWith(systemActive: value));
    } else if (key == 'pump_command') {
      emit(currentState.copyWith(pumpStatus: value));
    }

    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode({key: value}));
    _client!.publishMessage(
      'watertank/commands',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    debugPrint('📤 [MQTT] Відправлено команду: {$key: $value}');
  }

  void _startOperationGuard() {
    _timeGuardTimer?.cancel();
    _timeGuardTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isOperationalTime) {
        debugPrint('⏰ [TIME GUARD] Час вийшов. Відключаємо.');
        disconnect();
        emit(MqttBlocked('SYSTEM HALT: Shift ended'));
        await _logAction('SYSTEM HALT: Auto-disconnected');
      }
    });
  }

  void disconnect() {
    _timeGuardTimer?.cancel();
    _client?.disconnect();
    _client = null;
    if (state is! MqttBlocked) emit(MqttDisconnected());
  }

  @override
  Future<void> close() {
    _timeGuardTimer?.cancel();
    _client?.disconnect();
    return super.close();
  }
}
