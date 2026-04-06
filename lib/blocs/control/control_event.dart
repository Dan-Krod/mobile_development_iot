import 'package:mobile_development_iot/blocs/mqtt/mqtt_state.dart';

abstract class ControlEvent {}

class ToggleSystemEvent extends ControlEvent {
  final bool value;
  ToggleSystemEvent(this.value);
}

class TogglePumpEvent extends ControlEvent {
  final bool value;
  TogglePumpEvent(this.value);
}

class ToggleValveEvent extends ControlEvent {
  final bool value;
  ToggleValveEvent(this.value);
}

class SetAutoModeEvent extends ControlEvent {
  final bool value;
  SetAutoModeEvent(this.value);
}

class EmergencyShutdownEvent extends ControlEvent {}

class SyncMqttStateEvent extends ControlEvent {
  final MqttState mqttState;
  SyncMqttStateEvent(this.mqttState);
}
