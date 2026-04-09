class SecretModeState {
  final bool isSecretModeActive;
  const SecretModeState({this.isSecretModeActive = false});
}

class SecretModeUnsupportedOS extends SecretModeState {
  const SecretModeUnsupportedOS(bool currentState)
    : super(isSecretModeActive: currentState);
}

class SecretModeToggled extends SecretModeState {
  const SecretModeToggled(bool currentState)
    : super(isSecretModeActive: currentState);
}
