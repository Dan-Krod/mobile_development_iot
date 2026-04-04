import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {}

class ConnectivityOffline extends ConnectivityState {}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(ConnectivityInitial()) {
    _checkInitialStatus();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
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
