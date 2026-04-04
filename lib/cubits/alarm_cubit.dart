import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';

abstract class AlarmState {}

class AlarmLoading extends AlarmState {}

class AlarmLoaded extends AlarmState {
  final List<AlarmModel> alarms;
  AlarmLoaded(this.alarms);
}

class AlarmError extends AlarmState {
  final String message;
  AlarmError(this.message);
}

class AlarmCubit extends Cubit<AlarmState> {
  final IAlarmRepository _repository;
  final String tankId;

  AlarmCubit(this._repository, this.tankId) : super(AlarmLoading()) {
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    emit(AlarmLoading());
    try {
      final alarms = await _repository.getAlarmsByTank(tankId);
      emit(AlarmLoaded(alarms));
    } catch (e) {
      emit(AlarmError('Failed to load alarms'));
    }
  }

  Future<void> clearAlarms() async {
    try {
      await _repository.clearAlarms(tankId);
      emit(AlarmLoaded(const []));
    } catch (e) {
      emit(AlarmError('Failed to clear alarms'));
    }
  }

  Future<void> simulateAlarm() async {
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
      await loadAlarms();
    } catch (e) {
      emit(AlarmError('Failed to simulate alarm'));
    }
  }
}
