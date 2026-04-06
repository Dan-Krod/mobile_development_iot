import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/blocs/auth/auth_event.dart';
import 'package:mobile_development_iot/blocs/auth/auth_state.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<UpdateOperationalHoursEvent>(_onUpdateOperationalHours);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
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

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.login(event.email, event.password);
      if (success) {
        add(LoadCurrentUserEvent());
      } else {
        emit(AuthError('Invalid credentials or user not found.'));
      }
    } catch (e) {
      emit(AuthError('Network error during login.'));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerUser(event.user);
      emit(AuthAuthenticated(event.user, 10, 22));
    } catch (e) {
      emit(AuthError('REGISTRATION FAILED: NO SERVER CONNECTION'));
    }
  }

  Future<void> _onUpdateOperationalHours(
    UpdateOperationalHoursEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        await _authRepository.saveOperationalHours(event.start, event.end);
        emit(AuthAuthenticated(currentState.user, event.start, event.end));
      } catch (e) {
        emit(AuthError('Failed to save operational hours'));
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        await _authRepository.updateUser(event.user);
        emit(
          AuthAuthenticated(
            event.user,
            currentState.startHour,
            currentState.endHour,
          ),
        );
      } catch (e) {
        emit(AuthError('Failed to update profile.'));
        emit(currentState);
      }
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
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
      add(LoadCurrentUserEvent());
    }
  }
}
