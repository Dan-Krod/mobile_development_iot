import 'package:mobile_development_iot/models/alarm_model.dart';

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
