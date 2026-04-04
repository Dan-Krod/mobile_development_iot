import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';

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

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> loadCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final hours = await _authRepository.getOperationalHours();
        emit(AuthAuthenticated(user, hours['start'] ?? 10, hours['end'] ?? 22));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to load session'));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.login(email, password);
      if (success) {
        await loadCurrentUser();
      } else {
        emit(AuthError('Invalid credentials or user not found.'));
      }
    } catch (e) {
      emit(AuthError('Network error during login.'));
    }
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerUser(user);
      emit(AuthAuthenticated(user, 10, 22));
    } catch (e) {
      emit(AuthError('REGISTRATION FAILED: NO SERVER CONNECTION'));
    }
  }

  Future<void> updateOperationalHours(int start, int end) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        await _authRepository.saveOperationalHours(start, end);
        emit(AuthAuthenticated(currentState.user, start, end));
      } catch (e) {
        emit(AuthError('Failed to save operational hours'));
      }
    }
  }

  Future<void> updateProfile(UserModel user) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        await _authRepository.updateUser(user);
        emit(
          AuthAuthenticated(user, currentState.startHour, currentState.endHour),
        );
      } catch (e) {
        emit(AuthError('Failed to update profile.'));
        emit(currentState);
      }
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await _authRepository.deleteAccount();

      const storage = FlutterSecureStorage();
      await storage.deleteAll();

      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(
        AuthError('CRITICAL: Cannot delete account while server is offline'),
      );
      await loadCurrentUser();
    }
  }
}
