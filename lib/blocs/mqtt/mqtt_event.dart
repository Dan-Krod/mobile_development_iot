abstract class MqttEvent {}

class ConnectMqttEvent extends MqttEvent {
  final String brokerIp;
  ConnectMqttEvent(this.brokerIp);
}

class DisconnectMqttEvent extends MqttEvent {}

class SetOperationalHoursEvent extends MqttEvent {
  final int start;
  final int end;
  SetOperationalHoursEvent(this.start, this.end);
}

class SendMqttCommandEvent extends MqttEvent {
  final String key;
  final bool value;
  SendMqttCommandEvent(this.key, this.value);
}

class MqttMessageReceivedEvent extends MqttEvent {
  final String jsonString;
  MqttMessageReceivedEvent(this.jsonString);
}

class CheckTimeGuardEvent extends MqttEvent {}

class MqttDeviceTimeoutEvent extends MqttEvent {}
