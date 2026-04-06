import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_event.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_state.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

export 'mqtt_event.dart';
export 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final IAuthRepository _authRepo;
  final ApiClient _apiClient;

  MqttServerClient? _client;
  Timer? _timeGuardTimer;
  Timer? _deviceWatchdog;

  int shiftStartHour = 10;
  int shiftEndHour = 22;

  MqttBloc(this._authRepo, this._apiClient) : super(MqttInitial()) {
    on<ConnectMqttEvent>(_onConnect);
    on<DisconnectMqttEvent>(_onDisconnect);
    on<SetOperationalHoursEvent>(_onSetOperationalHours);
    on<SendMqttCommandEvent>(_onSendCommand);
    on<MqttMessageReceivedEvent>(_onMessageReceived);
    on<CheckTimeGuardEvent>(_onCheckTimeGuard);
    on<MqttDeviceTimeoutEvent>(_onDeviceTimeout);

    _loadOperationalHours();
  }

  void _startDeviceWatchdog() {
    _deviceWatchdog?.cancel();
    _deviceWatchdog = Timer(const Duration(seconds: 15), () {
      add(MqttDeviceTimeoutEvent());
    });
  }

  void _onDeviceTimeout(MqttDeviceTimeoutEvent event, Emitter<MqttState> emit) {
    if (state is MqttDataState) {
      debugPrint('⚠️ [WATCHDOG] ESP32 не відповідає. Статус: OFFLINE');
      emit((state as MqttDataState).copyWith(isDeviceOnline: false));
    }
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

  Future<void> _onSetOperationalHours(
    SetOperationalHoursEvent event,
    Emitter<MqttState> emit,
  ) async {
    debugPrint(
      '--- [MQTT] Отримано нові години:'
      '${event.start}:00 - ${event.end}:00 ---',
    );
    shiftStartHour = event.start;
    shiftEndHour = event.end;

    if (!_isOperationalTime) {
      debugPrint('🔒 [TIME GUARD] Час не підходить! Блокую систему.');
      await _logAction(
        'SYSTEM BLOCKED: Shift changed to ${event.start}:00-${event.end}:00 '
        '(Current time outside range)',
      );

      _client?.disconnect();
      _client = null;
      _timeGuardTimer?.cancel();

      emit(
        MqttBlocked(
          'ACCESS DENIED: Outside operational hours'
          '(${event.start}:00 - ${event.end}:00)',
        ),
      );
    } else {
      debugPrint('✅ [TIME GUARD] Час підходить. Знімаю блок.');
      if (state is MqttBlocked) {
        await _logAction(
          'SYSTEM UNBLOCKED: Shift changed to'
          '${event.start}:00-${event.end}:00',
        );
        emit(MqttDisconnected());
      }
    }
  }

  Future<void> _onConnect(
    ConnectMqttEvent event,
    Emitter<MqttState> emit,
  ) async {
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
            event.brokerIp,
            'lpnu_op_${DateTime.now().millisecondsSinceEpoch}',
          )
          ..port = 1883
          ..keepAlivePeriod = 20
          ..connectTimeoutPeriod = 5000
          ..onDisconnected = () {
            _timeGuardTimer?.cancel();
            debugPrint('❌ MQTT Відключено');
            add(DisconnectMqttEvent());
          };

    try {
      debugPrint('⏳ MQTT Підключення до ${event.brokerIp}...');
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
        final jsonString = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        add(MqttMessageReceivedEvent(jsonString));
      });

      _startOperationGuard();
    } catch (e) {
      debugPrint('🚨 MQTT Тайм-аут або помилка: $e');
      _client?.disconnect();
      emit(MqttDisconnected());
    }
  }

  void _onMessageReceived(
    MqttMessageReceivedEvent event,
    Emitter<MqttState> emit,
  ) {
    if (state is! MqttDataState) return;

    _startDeviceWatchdog();

    try {
      final data = jsonDecode(event.jsonString) as Map<String, dynamic>;
      final currentState = state as MqttDataState;
      emit(
        currentState.copyWith(
          temp: (data['temp'] as num?)?.toDouble(),
          level: (data['level'] as num?)?.toDouble(),
          pumpStatus: data['pump_status'] == true,
          localOverride: data['local_override'] == true,
          systemActive: data['sys_status'] == true,
          isDeviceOnline: true, // НОВЕ: Пристрій точно онлайн
        ),
      );
    } catch (_) {}
  }

  void _onSendCommand(SendMqttCommandEvent event, Emitter<MqttState> emit) {
    if (state is! MqttDataState || _client == null) return;
    final currentState = state as MqttDataState;
    if (currentState.localOverride) return;

    if (event.key == 'system_status') {
      emit(currentState.copyWith(systemActive: event.value));
    } else if (event.key == 'pump_command') {
      emit(currentState.copyWith(pumpStatus: event.value));
    }

    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode({event.key: event.value}));
    _client!.publishMessage(
      'watertank/commands',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    debugPrint('📤 [MQTT] Відправлено команду: {${event.key}: ${event.value}}');
  }

  void _startOperationGuard() {
    _timeGuardTimer?.cancel();
    _timeGuardTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(CheckTimeGuardEvent());
    });
  }

  Future<void> _onCheckTimeGuard(
    CheckTimeGuardEvent event,
    Emitter<MqttState> emit,
  ) async {
    if (!_isOperationalTime) {
      debugPrint('⏰ [TIME GUARD] Час вийшов. Відключаємо.');
      _client?.disconnect();
      _client = null;
      _timeGuardTimer?.cancel();

      emit(MqttBlocked('SYSTEM HALT: Shift ended'));
      await _logAction('SYSTEM HALT: Auto-disconnected');
    }
  }

  void _onDisconnect(DisconnectMqttEvent event, Emitter<MqttState> emit) {
    _timeGuardTimer?.cancel();
    _client?.disconnect();
    _deviceWatchdog?.cancel();
    _client = null;
    if (state is! MqttBlocked) emit(MqttDisconnected());
  }

  @override
  Future<void> close() {
    _timeGuardTimer?.cancel();
    _deviceWatchdog?.cancel();
    _client?.disconnect();
    return super.close();
  }
}
