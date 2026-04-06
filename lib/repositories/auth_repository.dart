import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';

abstract class IAuthRepository {
  Future<void> registerUser(UserModel user);
  Future<bool> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<void> deleteAccount();
  Future<void> saveOperationalHours(int start, int end);
  Future<Map<String, int>> getOperationalHours();
  Future<void> updateUser(UserModel user);
}

class SecureAuthRepository implements IAuthRepository {
  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'isLoggedIn';
  static const String _tokenKey = 'jwt_token';

  final _storage = const FlutterSecureStorage();
  final _api = ApiClient();

  @override
  Future<void> registerUser(UserModel user) async {
    await _api.register(user.toJson());
    final String userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
    await _storage.write(key: _sessionKey, value: 'true');
    debugPrint('PROD: Юзер зареєстрований і збережений локально');
  }

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.login(email, password);

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        final userData = response.data['user'];

        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _sessionKey, value: 'true');
        await _storage.write(key: _userKey, value: jsonEncode(userData));

        debugPrint('API: Успішний логін, токен збережено');
        return true;
      }
    } catch (e) {
      debugPrint('API Офлайн: Пробуємо локальний логін. $e');

      final String? userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final UserModel user = UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        if (user.email == email && user.password == password) {
          await _storage.write(key: _sessionKey, value: 'true');
          debugPrint('ЛОКАЛЬНО: Успішний логін без інтернету');
          return true;
        }
      }
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
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    if (user == null) return;

    await _api.deleteUser(user.email);
    await _storage.deleteAll();
    debugPrint('PROD: Акаунт видалено всюди');
  }

  @override
  Future<void> saveOperationalHours(int start, int end) async {
    await _storage.write(key: 'op_start', value: start.toString());
    await _storage.write(key: 'op_end', value: end.toString());
  }

  @override
  Future<Map<String, int>> getOperationalHours() async {
    final startStr = await _storage.read(key: 'op_start');
    final endStr = await _storage.read(key: 'op_end');

    return {
      'start': int.tryParse(startStr ?? '10') ?? 10,
      'end': int.tryParse(endStr ?? '22') ?? 22,
    };
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _api.updateUser({
        'email': user.email,
        'fullName': user.fullName,
        'hardware': user.hardware,
        'database': user.database,
      });
      debugPrint('API: Профіль оновлено (PUT)');
    } catch (e) {
      debugPrint('API Офлайн: Тільки локальне оновлення. $e');
    }

    final String userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }
}
