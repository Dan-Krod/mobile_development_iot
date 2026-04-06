import 'package:mobile_development_iot/models/tank_model.dart';

abstract class TankState {}

class TankLoading extends TankState {}

class TankLoaded extends TankState {
  final List<TankModel> tanks;
  TankLoaded(this.tanks);
}

class TankError extends TankState {
  final String message;
  TankError(this.message);
}

class TankAddSuccess extends TankState {
  final String message;
  TankAddSuccess(this.message);
}

class TankDeleteSuccess extends TankState {
  final String message;
  TankDeleteSuccess(this.message);
}

class TankActionError extends TankState {
  final String message;
  TankActionError(this.message);
}
