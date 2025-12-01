import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehiculo_model.dart';

class LocalStorageService {
  static const _vehiculosKey = 'cached_vehiculos';

  Future<void> guardarVehiculos(List<Vehiculo> vehiculos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(vehiculos.map((v) => v.toCacheMap()).toList());
    await prefs.setString(_vehiculosKey, jsonString);
  }

  Future<List<Vehiculo>> obtenerVehiculos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiculosKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    return data.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return Vehiculo.fromMap(map, map['id'] as String? ?? 'local');
    }).toList();
  }

  Future<void> limpiarVehiculos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehiculosKey);
  }
}
