import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/api_client.dart'; // Зміни шлях

abstract class ITankRepository {
  Future<List<TankModel>> getTanks();
  Future<void> saveTanks(List<TankModel> tanks);
  Future<void> addTank(TankModel tank);
  Future<void> deleteTank(String id);
}

class SecureTankRepository implements ITankRepository {
  static const String _tanksKey = 'system_tanks';
  final _storage = const FlutterSecureStorage();
  final _api = ApiClient();

  Future<String?> _getUserEmail() async {
    final userStr = await _storage.read(key: 'registered_user');
    if (userStr != null) {
      final userData = jsonDecode(userStr) as Map<String, dynamic>;
      return userData['email'] as String?;
    }
    return null;
  }

  @override
  Future<List<TankModel>> getTanks() async {
    final email = await _getUserEmail();

    if (email != null) {
      try {
        final response = await _api.getTanks(email);
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data as List<dynamic>;
          final tanks = data
              .map((item) => TankModel.fromJson(item as Map<String, dynamic>))
              .toList();

          await _saveLocally(tanks);
          debugPrint('API: Баки завантажено з сервера');
          return tanks;
        }
      } catch (e) {
        debugPrint('API Офлайн: Завантажуємо баки з локального кешу. $e');
      }
    }

    final String? tanksJson = await _storage.read(key: _tanksKey);

    if (tanksJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tanksJson) as List<dynamic>;
    return decoded
        .map((item) => TankModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocally(List<TankModel> tanks) async {
    final String encoded = jsonEncode(tanks.map((t) => t.toJson()).toList());
    await _storage.write(key: _tanksKey, value: encoded);
  }

  @override
  Future<void> saveTanks(List<TankModel> tanks) async {
    await _saveLocally(tanks);

    final email = await _getUserEmail();
    if (email != null) {
      for (var tank in tanks) {
        try {
          final data = tank.toJson();
          data['userEmail'] = email;
          await _api.saveTank(data);
        } catch (e) {
          debugPrint('API Офлайн: Не вдалося синхронізувати бак ${tank.id}');
        }
      }
    }
  }

  @override
  Future<void> addTank(TankModel tank) async {
    final tanks = await getTanks();
    tanks.add(tank);
    await saveTanks(tanks);
  }

  @override
  Future<void> deleteTank(String id) async {
    final tanks = await getTanks();
    tanks.removeWhere((t) => t.id == id);
    await saveTanks(tanks);
  }
}
