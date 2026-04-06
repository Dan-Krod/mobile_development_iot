import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/connectivity/connectivity_event.dart';
import 'package:mobile_development_iot/blocs/connectivity/connectivity_state.dart';

export 'connectivity_event.dart';
export 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckInitialConnectivityEvent>(_onCheckInitial);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);

    add(CheckInitialConnectivityEvent());

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      add(ConnectivityChangedEvent(results));
    });
  }

  Future<void> _onCheckInitial(
    CheckInitialConnectivityEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    final results = await _connectivity.checkConnectivity();
    _emitStateBasedOnResults(results, emit);
  }

  void _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<ConnectivityState> emit,
  ) {
    _emitStateBasedOnResults(event.results, emit);
  }

  void _emitStateBasedOnResults(
    List<ConnectivityResult> results,
    Emitter<ConnectivityState> emit,
  ) {
    final isOffline =
        results.isEmpty || results.contains(ConnectivityResult.none);

    if (isOffline) {
      if (state is! ConnectivityOffline) {
        emit(ConnectivityOffline());
      }
    } else {
      if (state is! ConnectivityOnline) {
        emit(ConnectivityOnline());
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
