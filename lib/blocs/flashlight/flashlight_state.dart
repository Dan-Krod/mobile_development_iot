class FlashlightState {
  final bool isOn;
  const FlashlightState({this.isOn = false});
}

class FlashlightUnsupportedOS extends FlashlightState {
  const FlashlightUnsupportedOS(bool isOn) : super(isOn: isOn);
}
