import 'package:mobile_development_iot/models/tank_model.dart';

abstract class TankEvent {}

class LoadTanksEvent extends TankEvent {}

class AddTankEvent extends TankEvent {
  final TankModel tank;
  AddTankEvent(this.tank);
}

class DeleteTankEvent extends TankEvent {
  final String id;
  DeleteTankEvent(this.id);
}
