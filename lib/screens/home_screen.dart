import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'add_edit_vehiculo_screen.dart';
import 'vehicle_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _cacheService = LocalStorageService();
  List<Vehiculo> _cachedVehiculos = [];

  @override
  void initState() {
    super.initState();
    _loadCachedVehiculos();
  }

  Future<void> _loadCachedVehiculos() async {
    final cached = await _cacheService.obtenerVehiculos();
    if (!mounted) return;
    setState(() {
      _cachedVehiculos = cached;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zenith Flota'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditVehiculoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Vehiculo>>(
        stream: _firestoreService.getVehiculos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (_cachedVehiculos.isNotEmpty) {
              return _buildVehicleList(_cachedVehiculos, offline: true);
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final vehiculos = snapshot.data!;
            _cachedVehiculos = vehiculos;
            unawaited(_cacheService.guardarVehiculos(vehiculos));
            if (vehiculos.isEmpty) {
              return const Center(child: Text('No hay vehículos registrados.'));
            }
            return _buildVehicleList(vehiculos);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            if (_cachedVehiculos.isNotEmpty) {
              return _buildVehicleList(_cachedVehiculos, offline: true);
            }
            return const Center(child: CircularProgressIndicator());
          }

          if (_cachedVehiculos.isNotEmpty) {
            return _buildVehicleList(_cachedVehiculos, offline: true);
          }

          return const Center(child: Text('No hay vehículos registrados.'));
        },
      ),
    );
  }

  Widget _buildVehicleList(List<Vehiculo> vehiculos, {bool offline = false}) {
    return Column(
      children: [
        if (offline)
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Mostrando datos almacenados localmente (sin conexión)',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: vehiculos.length,
            itemBuilder: (context, index) {
              final vehiculo = vehiculos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    color: vehiculo.estado == 'Operativo' ? Colors.green : Colors.red,
                    size: 40,
                  ),
                  title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
                  subtitle: Text('Matrícula: ${vehiculo.matricula} \nKm: ${vehiculo.kilometraje}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(vehiculo: vehiculo),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}