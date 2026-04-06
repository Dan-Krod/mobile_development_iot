abstract class MqttState {}

class MqttInitial extends MqttState {}

class MqttDisconnected extends MqttState {}

class MqttConnecting extends MqttState {}

class MqttDataState extends MqttState {
  final double temp;
  final double level;
  final bool pumpStatus;
  final bool localOverride;
  final bool systemActive;
  final bool isDeviceOnline;

  MqttDataState({
    required this.temp,
    required this.level,
    required this.pumpStatus,
    required this.localOverride,
    required this.systemActive,
    this.isDeviceOnline = false,
  });

  MqttDataState copyWith({
    double? temp,
    double? level,
    bool? pumpStatus,
    bool? localOverride,
    bool? systemActive,
    bool? isDeviceOnline,
  }) {
    return MqttDataState(
      temp: temp ?? this.temp,
      level: level ?? this.level,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      localOverride: localOverride ?? this.localOverride,
      systemActive: systemActive ?? this.systemActive,
      isDeviceOnline: isDeviceOnline ?? this.isDeviceOnline,
    );
  }
}

class MqttBlocked extends MqttState {
  final String reason;
  MqttBlocked(this.reason);
}
