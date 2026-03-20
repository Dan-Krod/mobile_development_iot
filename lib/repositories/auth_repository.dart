import 'dart:convert';

import 'package:mobile_development_iot/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> registerUser(UserModel user);
  Future<bool> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<void> deleteAccount();
}

class SharedPrefsAuthRepository implements IAuthRepository {
  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'isLoggedIn';

  @override
  Future<void> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_sessionKey, true);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);

    if (userJson == null) return false;

    final UserModel user = UserModel.fromJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    );

    if (user.email == email && user.password == password) {
      await prefs.setBool(_sessionKey, true);
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
  }

  @override
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
