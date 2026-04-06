import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/alarm/alarm_event.dart';
import 'package:mobile_development_iot/blocs/alarm/alarm_state.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';

export 'alarm_event.dart';
export 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final IAlarmRepository _repository;
  final String tankId;

  AlarmBloc(this._repository, this.tankId) : super(AlarmLoading()) {
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<ClearAlarmsEvent>(_onClearAlarms);
    on<SimulateAlarmEvent>(_onSimulateAlarm);

    add(LoadAlarmsEvent());
  }

  Future<void> _onLoadAlarms(
    LoadAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());
    try {
      final alarms = await _repository.getAlarmsByTank(tankId);
      emit(AlarmLoaded(alarms));
    } catch (e) {
      emit(AlarmError('Failed to load alarms'));
    }
  }

  Future<void> _onClearAlarms(
    ClearAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await _repository.clearAlarms(tankId);
      emit(AlarmLoaded(const []));
    } catch (e) {
      emit(AlarmError('Failed to clear alarms'));
    }
  }

  Future<void> _onSimulateAlarm(
    SimulateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    final now = DateTime.now();
    final newAlarm = AlarmModel(
      id: now.millisecondsSinceEpoch.toString(),
      tankId: tankId,
      message: 'System alert: unusual pressure detected!',
      time: '${now.hour}:${now.minute}:${now.second}',
      isCritical: now.second % 2 == 0,
    );
    try {
      await _repository.addAlarm(newAlarm);
      add(LoadAlarmsEvent());
    } catch (e) {
      emit(AlarmError('Failed to simulate alarm'));
    }
  }
}
