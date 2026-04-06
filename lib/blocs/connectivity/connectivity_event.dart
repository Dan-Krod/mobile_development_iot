import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityEvent {}

class CheckInitialConnectivityEvent extends ConnectivityEvent {}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final List<ConnectivityResult> results;
  ConnectivityChangedEvent(this.results);
}
