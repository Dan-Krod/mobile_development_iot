import 'package:mobile_development_iot/models/user_model.dart';

abstract class AuthEvent {}

class LoadCurrentUserEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class RegisterEvent extends AuthEvent {
  final UserModel user;
  RegisterEvent(this.user);
}

class UpdateOperationalHoursEvent extends AuthEvent {
  final int start;
  final int end;
  UpdateOperationalHoursEvent(this.start, this.end);
}

class UpdateProfileEvent extends AuthEvent {
  final UserModel user;
  UpdateProfileEvent(this.user);
}

class LogoutEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}
