import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'add_edit_vehiculo_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';
import 'vehicle_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userRole});

  final String userRole;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _cacheService = LocalStorageService();
  final _authService = AuthService();
  List<Vehiculo> _cachedVehiculos = [];
  late final Stream<List<Vehiculo>> _vehiculosStream;

  @override
  void initState() {
    super.initState();
    _vehiculosStream = _firestoreService.getVehiculos().asBroadcastStream();
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
    final isAdmin = widget.userRole == 'admin';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zenith Flota'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          StreamBuilder<List<Vehiculo>>(
            stream: _vehiculosStream,
            builder: (context, snapshot) {
              final alertCount = snapshot.data
                      ?.where((vehiculo) => vehiculo.requiereAlerta)
                      .length ??
                  0;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (alertCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            alertCount.toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlertsScreen(canEdit: isAdmin),
                    ),
                  );
                },
                tooltip: 'Alertas',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditVehiculoScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Vehiculo>>(
        stream: _vehiculosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (_cachedVehiculos.isNotEmpty) {
              return _buildVehicleList(
                _cachedVehiculos,
                offline: true,
                canEdit: isAdmin,
              );
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
            return _buildVehicleList(vehiculos, canEdit: isAdmin);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            if (_cachedVehiculos.isNotEmpty) {
              return _buildVehicleList(
                _cachedVehiculos,
                offline: true,
                canEdit: isAdmin,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          if (_cachedVehiculos.isNotEmpty) {
            return _buildVehicleList(
              _cachedVehiculos,
              offline: true,
              canEdit: isAdmin,
            );
          }

          return const Center(child: Text('No hay vehículos registrados.'));
        },
      ),
    );
  }

  Widget _buildVehicleList(
    List<Vehiculo> vehiculos, {
    bool offline = false,
    required bool canEdit,
  }) {
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
                        builder: (_) => VehicleDetailScreen(
                          vehiculo: vehiculo,
                          canEdit: canEdit,
                        ),
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