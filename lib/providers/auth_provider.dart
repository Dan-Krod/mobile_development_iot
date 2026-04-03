import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoggedIn = false;

  int shiftStartHour = 10;
  int shiftEndHour = 22;

  AuthProvider(this._authRepository);

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadSession() async {
    _currentUser = await _authRepository.getCurrentUser();
    _isLoggedIn = _currentUser != null;

    await loadOperationalHours();

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await _authRepository.login(email, password);
    if (success) await loadSession();
    return success;
  }

  Future<void> register(UserModel user) async {
    await _authRepository.registerUser(user);
    await loadSession();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> loadOperationalHours() async {
    final hours = await _authRepository.getOperationalHours();
    shiftStartHour = hours['start'] ?? 10;
    shiftEndHour = hours['end'] ?? 22;
    notifyListeners();
  }

  Future<void> saveOperationalHours(int start, int end) async {
    await _authRepository.saveOperationalHours(start, end);
    shiftStartHour = start;
    shiftEndHour = end;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    await _authRepository.updateUser(user);
    await loadSession();
  }
}
