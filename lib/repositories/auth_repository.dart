import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/user_model.dart';

abstract class IAuthRepository {
  Future<void> registerUser(UserModel user);
  Future<bool> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<void> deleteAccount();
}

class SecureAuthRepository implements IAuthRepository {
  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'isLoggedIn';

  final _storage = const FlutterSecureStorage();

  @override
  Future<void> registerUser(UserModel user) async {
    final String userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
    await _storage.write(key: _sessionKey, value: 'true');
  }

  @override
  Future<bool> login(String email, String password) async {
    final String? userJson = await _storage.read(key: _userKey);

    if (userJson == null) return false;

    final UserModel user = UserModel.fromJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    );

    if (user.email == email && user.password == password) {
      await _storage.write(key: _sessionKey, value: 'true');
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final String? userJson = await _storage.read(key: _userKey);
    final String? sessionActive = await _storage.read(key: _sessionKey);

    if (userJson == null || sessionActive != 'true') return null;

    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }

  @override
  Future<void> deleteAccount() async {
    await _storage.deleteAll();
  }
}
