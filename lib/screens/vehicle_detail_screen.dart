import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../models/mantenimiento_model.dart';
import '../models/recurso_consumo_model.dart';
import '../models/conductor_model.dart';
import '../services/mantenimiento_service.dart';
import '../services/recurso_service.dart';
import '../services/conductor_service.dart';
import '../services/firestore_service.dart';
import 'add_edit_mantenimiento_screen.dart';
import 'assign_driver_screen.dart';
import 'add_resource_log_screen.dart';
import 'add_edit_vehiculo_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehiculo vehiculo;
  const VehicleDetailScreen({super.key, required this.vehiculo});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _vehiculoService = FirestoreService();
  final _mantenimientoService = MantenimientoService();
  final _recursoService = RecursoService();
  final _conductorService = ConductorService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Vehiculo>(
      stream: _vehiculoService.getVehiculo(widget.vehiculo.id),
      initialData: widget.vehiculo,
      builder: (context, snapshot) {
        final vehiculo = snapshot.data ?? widget.vehiculo;
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalle ${vehiculo.matricula}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditVehiculoScreen(vehiculo: vehiculo),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehicleHeader(context, vehiculo),
                const SizedBox(height: 24),
                _buildSectionTitle('Mantenimientos programados', onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditMantenimientoScreen(vehiculo: vehiculo),
                    ),
                  );
                }),
                _buildMaintenanceList(vehiculo),
                const SizedBox(height: 24),
                _buildSectionTitle('Consumo de recursos', onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddResourceLogScreen(vehiculo: vehiculo),
                    ),
                  );
                }),
                _buildResourceList(vehiculo),
                const SizedBox(height: 24),
                _buildSectionTitle('Conductores disponibles', onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssignDriverScreen(vehiculo: vehiculo),
                    ),
                  );
                }),
                _buildDriverList(vehiculo),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleHeader(BuildContext context, Vehiculo vehiculo) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: vehiculo.estado == 'Operativo' ? Colors.green : Colors.orange,
                  size: 42,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehiculo.marca} ${vehiculo.modelo}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Matrícula: ${vehiculo.matricula}'),
                      Text('Kilometraje: ${vehiculo.kilometraje} km'),
                      Text('Estado: ${vehiculo.estado}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.build_circle, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehiculo.proximoMantenimiento == null
                        ? 'No hay mantenimiento programado.'
                        : 'Próximo mantenimiento: '
                            '${vehiculo.proximoMantenimiento!.day.toString().padLeft(2, '0')}/'
                            '${vehiculo.proximoMantenimiento!.month.toString().padLeft(2, '0')}/'
                            '${vehiculo.proximoMantenimiento!.year}',
                    style: TextStyle(
                      color: vehiculo.requiereAlerta ? Colors.red : Colors.black,
                      fontWeight: vehiculo.requiereAlerta ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            if (vehiculo.tecnicoAsignado.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Técnico asignado: ${vehiculo.tecnicoAsignado}'),
            ],
            if (vehiculo.conductorAsignadoId.isNotEmpty) ...[
              const SizedBox(height: 8),
              StreamBuilder<Conductor?>(
                stream: _conductorService.obtenerConductorPorId(
                  vehiculo.conductorAsignadoId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Cargando conductor asignado...');
                  }
                  final conductor = snapshot.data;
                  if (conductor == null) {
                    return const Text('Conductor asignado no disponible');
                  }
                  return Text('Conductor asignado: ${conductor.nombre}');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
          ),
      ],
    );
  }

  Widget _buildMaintenanceList(Vehiculo vehiculo) {
    return StreamBuilder<List<Mantenimiento>>(
      stream: _mantenimientoService.porVehiculo(vehiculo.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final mantenimientos = snapshot.data ?? [];
        if (mantenimientos.isEmpty) {
          return const Text('Sin mantenimientos registrados.');
        }
        return Column(
          children: mantenimientos.map((mantenimiento) {
            final vencido = mantenimiento.estaVencido;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(
                Icons.warning,
                color: vencido ? Colors.red : Colors.green,
              ),
              title: Text('${mantenimiento.tipo} - ${mantenimiento.tecnico.isEmpty ? 'Sin técnico' : mantenimiento.tecnico}'),
              subtitle: Text(
                'Programado: '
                '${mantenimiento.fechaProgramada.day.toString().padLeft(2, '0')}/'
                '${mantenimiento.fechaProgramada.month.toString().padLeft(2, '0')}/'
                '${mantenimiento.fechaProgramada.year}\n'
                'Estado: ${mantenimiento.estado}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditMantenimientoScreen(
                        vehiculo: vehiculo,
                        mantenimiento: mantenimiento,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildResourceList(Vehiculo vehiculo) {
    return StreamBuilder<List<RecursoConsumo>>(
      stream: _recursoService.porVehiculo(vehiculo.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final registros = snapshot.data ?? [];
        if (registros.isEmpty) {
          return const Text('Sin consumos registrados.');
        }
        return Column(
          children: registros.map((registro) {
            return ListTile(
              leading: const Icon(Icons.local_gas_station),
              title: Text('${registro.tipo} - ${registro.cantidad} ${registro.unidad}'),
              subtitle: Text(
                '${registro.fecha.day.toString().padLeft(2, '0')}/'
                '${registro.fecha.month.toString().padLeft(2, '0')}/'
                '${registro.fecha.year}\n${registro.observaciones}',
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDriverList(Vehiculo vehiculo) {
    return StreamBuilder<List<Conductor>>(
      stream: _conductorService.obtenerConductores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final conductores = snapshot.data ?? [];
        if (conductores.isEmpty) {
          return const Text('No hay conductores registrados.');
        }
        return Column(
          children: conductores.map((conductor) {
            final asignado = conductor.id == vehiculo.conductorAsignadoId;
            return ListTile(
              leading: Icon(
                Icons.person,
                color: asignado
                    ? Colors.blueAccent
                    : (conductor.disponible ? Colors.green : Colors.grey),
              ),
              title: Text(
                conductor.nombre,
                style: TextStyle(fontWeight: asignado ? FontWeight.bold : FontWeight.normal),
              ),
              subtitle: Text('Tel: ${conductor.telefono} - Licencia: ${conductor.licencia}'),
              trailing: asignado
                  ? const Chip(
                      label: Text('Asignado'),
                      backgroundColor: Color(0xFFE3F2FD),
                    )
                  : null,
            );
          }).toList(),
        );
      },
    );
  }
}
