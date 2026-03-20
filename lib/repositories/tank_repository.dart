import 'dart:convert';

import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ITankRepository {
  Future<List<TankModel>> getTanks();
  Future<void> saveTanks(List<TankModel> tanks);
  Future<void> addTank(TankModel tank);
  Future<void> deleteTank(String id);
}

class SharedPrefsTankRepository implements ITankRepository {
  static const String _tanksKey = 'system_tanks';

  @override
  Future<List<TankModel>> getTanks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tanksJson = prefs.getString(_tanksKey);

    if (tanksJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tanksJson) as List<dynamic>;
    return decoded
        .map((item) => TankModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTanks(List<TankModel> tanks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tanks.map((t) => t.toJson()).toList());
    await prefs.setString(_tanksKey, encoded);
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
