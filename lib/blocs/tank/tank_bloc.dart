import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/tank/tank_event.dart';
import 'package:mobile_development_iot/blocs/tank/tank_state.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
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
    final currentState = state;
    List<TankModel> currentTanks = [];
    if (currentState is TankLoaded) currentTanks = currentState.tanks;

    try {
      await _tankRepository.addTank(event.tank);
      emit(TankAddSuccess('NODE ADDED SUCCESSFULLY'));

      if (currentTanks.isNotEmpty) {
        emit(TankLoaded([...currentTanks, event.tank]));
      } else {
        add(LoadTanksEvent());
      }
    } catch (e) {
      emit(TankActionError('Failed to add node: Server error'));
      if (currentTanks.isNotEmpty) emit(TankLoaded(currentTanks));
    }
  }

  Future<void> _onDeleteTank(
    DeleteTankEvent event,
    Emitter<TankState> emit,
  ) async {
    final currentState = state;
    List<TankModel> currentTanks = [];
    if (currentState is TankLoaded) currentTanks = currentState.tanks;

    try {
      await _tankRepository.deleteTank(event.id);

      emit(TankDeleteSuccess('NODE TERMINATED'));

      if (currentTanks.isNotEmpty) {
        final updatedTanks = currentTanks
            .where((t) => t.id != event.id)
            .toList();
        emit(TankLoaded(updatedTanks));
      } else {
        add(LoadTanksEvent());
      }
    } catch (e) {
      if (e.toString().contains('BACKEND_OFFLINE')) {
        emit(TankActionError('CRITICAL: BACKEND SERVER IS DOWN'));
      } else {
        emit(TankActionError('Failed to delete node. Check connection.'));
      }

      if (currentTanks.isNotEmpty) {
        emit(TankLoaded(currentTanks));
      } else {
        add(LoadTanksEvent());
      }
    }
  }
}
