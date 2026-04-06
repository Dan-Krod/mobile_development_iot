import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/control/control_event.dart';
import 'package:mobile_development_iot/blocs/control/control_state.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_bloc.dart';

export 'control_event.dart';
export 'control_state.dart';

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  final MqttBloc _mqttBloc;
  final bool _isHardware;
  StreamSubscription<dynamic>? _mqttSubscription;

  ControlBloc(this._mqttBloc, this._isHardware) : super(ControlState()) {
    on<ToggleSystemEvent>(_onToggleSystem);
    on<TogglePumpEvent>(_onTogglePump);
    on<ToggleValveEvent>(_onToggleValve);
    on<SetAutoModeEvent>(_onSetAutoMode);
    on<EmergencyShutdownEvent>(_onEmergencyShutdown);
    on<SyncMqttStateEvent>(_onSyncMqttState);

    if (_isHardware) {
      add(SyncMqttStateEvent(_mqttBloc.state));

      _mqttSubscription = _mqttBloc.stream.listen((mqttState) {
        add(SyncMqttStateEvent(mqttState));
      });
    }
  }

  void _onSyncMqttState(SyncMqttStateEvent event, Emitter<ControlState> emit) {
    if (event.mqttState is MqttDataState) {
      final dataState = event.mqttState as MqttDataState;
      emit(
        state.copyWith(
          systemPower: dataState.systemActive,
          pumpState: dataState.pumpStatus,
        ),
      );
    }
  }

  void _onToggleSystem(ToggleSystemEvent event, Emitter<ControlState> emit) {
    emit(state.copyWith(systemPower: event.value));
    if (_isHardware) {
      _mqttBloc.add(SendMqttCommandEvent('system_status', event.value));
    }
  }

  void _onTogglePump(TogglePumpEvent event, Emitter<ControlState> emit) {
    emit(state.copyWith(pumpState: event.value));
    if (_isHardware) {
      _mqttBloc.add(SendMqttCommandEvent('pump_command', event.value));
    }
  }

  void _onToggleValve(ToggleValveEvent event, Emitter<ControlState> emit) {
    emit(state.copyWith(valveState: event.value));
    if (_isHardware) {
      _mqttBloc.add(SendMqttCommandEvent('valve_command', event.value));
    }
  }

  void _onSetAutoMode(SetAutoModeEvent event, Emitter<ControlState> emit) {
    emit(state.copyWith(isAutoMode: event.value));
    if (_isHardware) {
      _mqttBloc.add(SendMqttCommandEvent('auto_mode', event.value));
    }
  }

  void _onEmergencyShutdown(
    EmergencyShutdownEvent event,
    Emitter<ControlState> emit,
  ) {
    emit(ControlState());

    if (_isHardware) {
      _mqttBloc.add(SendMqttCommandEvent('system_status', false));
      _mqttBloc.add(SendMqttCommandEvent('pump_command', false));
      _mqttBloc.add(SendMqttCommandEvent('valve_command', false));
    }
  }

  @override
  Future<void> close() {
    _mqttSubscription?.cancel();
    return super.close();
  }
}
