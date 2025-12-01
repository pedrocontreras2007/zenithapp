import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/firestore_service.dart';
import 'vehicle_detail_screen.dart';

class AlertsScreen extends StatelessWidget {
  AlertsScreen({super.key, required this.canEdit});

  final FirestoreService _firestoreService = FirestoreService();
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de mantenimiento')),
      body: StreamBuilder<List<Vehiculo>>(
        stream: _firestoreService.getVehiculos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alertas = snapshot.data!
              .where((vehiculo) => vehiculo.requiereAlerta)
              .toList();
          if (alertas.isEmpty) {
            return const Center(child: Text('No hay mantenimientos urgentes.'));
          }
          return ListView.builder(
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final vehiculo = alertas[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
                  subtitle: Text('Próximo mantenimiento: '
                      '${vehiculo.proximoMantenimiento?.day.toString().padLeft(2, '0')}/'
                      '${vehiculo.proximoMantenimiento?.month.toString().padLeft(2, '0')}/'
                      '${vehiculo.proximoMantenimiento?.year}'),
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
          );
        },
      ),
    );
  }
}
