import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/mqtt_cubit.dart';

class ControlState {
  final bool systemPower;
  final bool pumpState;
  final bool valveState;
  final bool isAutoMode;

  ControlState({
    this.systemPower = false,
    this.pumpState = false,
    this.valveState = false,
    this.isAutoMode = false,
  });

  ControlState copyWith({
    bool? systemPower,
    bool? pumpState,
    bool? valveState,
    bool? isAutoMode,
  }) {
    return ControlState(
      systemPower: systemPower ?? this.systemPower,
      pumpState: pumpState ?? this.pumpState,
      valveState: valveState ?? this.valveState,
      isAutoMode: isAutoMode ?? this.isAutoMode,
    );
  }
}

class ControlCubit extends Cubit<ControlState> {
  final MqttCubit _mqttCubit;
  final bool _isHardware;
  StreamSubscription<dynamic>? _mqttSubscription;

  ControlCubit(this._mqttCubit, this._isHardware) : super(ControlState()) {
    if (_isHardware) {
      _syncWithMqtt(_mqttCubit.state);

      _mqttSubscription = _mqttCubit.stream.listen(_syncWithMqtt);
    }
  }

  void _syncWithMqtt(MqttState mqttState) {
    if (mqttState is MqttDataState) {
      emit(
        state.copyWith(
          systemPower: mqttState.systemActive,
          pumpState: mqttState.pumpStatus,
        ),
      );
    }
  }

  void toggleSystem(bool val) {
    emit(state.copyWith(systemPower: val));
    if (_isHardware) _mqttCubit.sendCommand('system_status', val);
  }

  void togglePump(bool val) {
    emit(state.copyWith(pumpState: val));
    if (_isHardware) _mqttCubit.sendCommand('pump_command', val);
  }

  void toggleValve(bool val) {
    emit(state.copyWith(valveState: val));
    if (_isHardware) _mqttCubit.sendCommand('valve_command', val);
  }

  void setAutoMode(bool val) {
    emit(state.copyWith(isAutoMode: val));
    if (_isHardware) _mqttCubit.sendCommand('auto_mode', val);
  }

  void emergencyShutdown() {
    emit(ControlState());

    if (_isHardware) {
      _mqttCubit.sendCommand('system_status', false);
      _mqttCubit.sendCommand('pump_command', false);
      _mqttCubit.sendCommand('valve_command', false);
    }
  }

  @override
  Future<void> close() {
    _mqttSubscription?.cancel();
    return super.close();
  }
}
