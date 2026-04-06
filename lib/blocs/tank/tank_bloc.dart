import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/tank/tank_event.dart';
import 'package:mobile_development_iot/blocs/tank/tank_state.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';

export 'tank_event.dart';
export 'tank_state.dart';

class TankBloc extends Bloc<TankEvent, TankState> {
  final ITankRepository _tankRepository;

  TankBloc(this._tankRepository) : super(TankLoading()) {
    on<LoadTanksEvent>(_onLoadTanks);
    on<AddTankEvent>(_onAddTank);
    on<DeleteTankEvent>(_onDeleteTank);
  }

  Future<void> _onLoadTanks(
    LoadTanksEvent event,
    Emitter<TankState> emit,
  ) async {
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

  Future<void> _onAddTank(AddTankEvent event, Emitter<TankState> emit) async {
    try {
      await _tankRepository.addTank(event.tank);
      emit(TankAddSuccess('NODE ADDED SUCCESSFULLY'));

      add(LoadTanksEvent());
    } catch (e) {
      emit(TankActionError('Failed to add node: Server error'));
      add(LoadTanksEvent());
    }
  }

  Future<void> _onDeleteTank(
    DeleteTankEvent event,
    Emitter<TankState> emit,
  ) async {
    try {
      await _tankRepository.deleteTank(event.id);
      emit(TankDeleteSuccess('NODE TERMINATED'));

      add(LoadTanksEvent());
    } catch (e) {
      if (e.toString().contains('BACKEND_OFFLINE')) {
        emit(TankActionError('CRITICAL: BACKEND SERVER IS DOWN'));
      } else {
        emit(TankActionError('Failed to delete node. Check connection.'));
      }
      add(LoadTanksEvent());
    }
  }
}
