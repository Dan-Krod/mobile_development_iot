abstract class SecretModeEvent {}

class RegisterSecretTapEvent extends SecretModeEvent {}

class RegisterSecretShakeEvent extends SecretModeEvent {}

class EvaluateShakeTimeoutEvent extends SecretModeEvent {}
