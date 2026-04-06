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
