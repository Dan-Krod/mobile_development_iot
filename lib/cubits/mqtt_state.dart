part of 'mqtt_cubit.dart';

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

  MqttDataState({
    required this.temp,
    required this.level,
    required this.pumpStatus,
    required this.localOverride,
    required this.systemActive,
  });

  MqttDataState copyWith({
    double? temp,
    double? level,
    bool? pumpStatus,
    bool? localOverride,
    bool? systemActive,
  }) {
    return MqttDataState(
      temp: temp ?? this.temp,
      level: level ?? this.level,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      localOverride: localOverride ?? this.localOverride,
      systemActive: systemActive ?? this.systemActive,
    );
  }
}

class MqttBlocked extends MqttState {
  final String reason;
  MqttBlocked(this.reason);
}
