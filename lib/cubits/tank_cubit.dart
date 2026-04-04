import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';

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

class TankCubit extends Cubit<TankState> {
  final ITankRepository _tankRepository;

  TankCubit(this._tankRepository) : super(TankLoading());

  Future<void> loadTanks() async {
    if (state is! TankLoaded) {
      emit(TankLoading());
    }

    try {
      final tanks = await _tankRepository.getTanks();
      emit(TankLoaded(tanks));
    } catch (e) {
      emit(TankError('Failed to load tanks.'));
    }
  }

  Future<void> addTank(TankModel tank) async {
    try {
      await _tankRepository.addTank(tank);

      emit(TankAddSuccess('NODE ADDED SUCCESSFULLY'));

      await loadTanks();
    } catch (e) {
      emit(TankActionError('Failed to add node: Server error'));
      await loadTanks();
    }
  }

  Future<void> deleteTank(String id) async {
    try {
      await _tankRepository.deleteTank(id);

      emit(TankDeleteSuccess('NODE TERMINATED'));

      await loadTanks();
    } catch (e) {
      if (e.toString().contains('BACKEND_OFFLINE')) {
        emit(TankActionError('CRITICAL: BACKEND SERVER IS DOWN'));
      } else {
        emit(TankActionError('Failed to delete node. Check connection.'));
      }
      await loadTanks();
    }
  }
}
