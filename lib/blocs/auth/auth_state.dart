import 'package:mobile_development_iot/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final int startHour;
  final int endHour;
  AuthAuthenticated(this.user, this.startHour, this.endHour);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
