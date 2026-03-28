import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/models/tank_model.dart';

abstract class ITankRepository {
  Future<List<TankModel>> getTanks();
  Future<void> saveTanks(List<TankModel> tanks);
  Future<void> addTank(TankModel tank);
  Future<void> deleteTank(String id);
}

class SecureTankRepository implements ITankRepository {
  static const String _tanksKey = 'system_tanks';
  final _storage = const FlutterSecureStorage();

  @override
  Future<List<TankModel>> getTanks() async {
    final String? tanksJson = await _storage.read(key: _tanksKey);

    if (tanksJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tanksJson) as List<dynamic>;
    return decoded
        .map((item) => TankModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTanks(List<TankModel> tanks) async {
    final String encoded = jsonEncode(tanks.map((t) => t.toJson()).toList());
    await _storage.write(key: _tanksKey, value: encoded);
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
