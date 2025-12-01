import 'package:flutter/material.dart';
import '../models/conductor_model.dart';
import '../models/vehiculo_model.dart';
import '../services/conductor_service.dart';
import '../services/firestore_service.dart';

class AssignDriverScreen extends StatefulWidget {
  final Vehiculo vehiculo;
  const AssignDriverScreen({super.key, required this.vehiculo});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  final _conductorService = ConductorService();
  final _vehiculoService = FirestoreService();
  String? _selectedDriverId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDriverId = widget.vehiculo.conductorAsignadoId.isEmpty
        ? null
        : widget.vehiculo.conductorAsignadoId;
  }

  Future<void> _assignDriver() async {
    if (_selectedDriverId == null) return;
    setState(() => _loading = true);
    var guardado = false;
    try {
      await _vehiculoService.actualizarCamposVehiculo(
        widget.vehiculo.id,
        {'conductorAsignadoId': _selectedDriverId},
      );
      guardado = true;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo asignar el conductor: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (guardado) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _createDriver() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final licenciaController = TextEditingController();
    final telefonoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuevo conductor'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: licenciaController,
                decoration: const InputDecoration(labelText: 'Licencia'),
              ),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final conductor = Conductor(
                id: '',
                nombre: nombreController.text.trim(),
                licencia: licenciaController.text.trim(),
                telefono: telefonoController.text.trim(),
              );
              await _conductorService.registrar(conductor);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar conductor')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Conductor>>(
              stream: _conductorService.obtenerConductores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final conductores = snapshot.data ?? [];
                if (conductores.isEmpty) {
                  return const Center(child: Text('No existen conductores registrados.'));
                }
                return ListView.builder(
                  itemCount: conductores.length,
                  itemBuilder: (_, index) {
                    final conductor = conductores[index];
                    final seleccionado = conductor.id == _selectedDriverId;
                    return ListTile(
                      onTap: () => setState(() => _selectedDriverId = conductor.id),
                      leading: Icon(
                        seleccionado
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: seleccionado ? Colors.blueAccent : Colors.grey,
                      ),
                      title: Text(conductor.nombre),
                      subtitle: Text(
                        conductor.licencia.isEmpty
                            ? 'Sin licencia'
                            : conductor.licencia,
                      ),
                      trailing: Text(conductor.telefono),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _assignDriver,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Asignar conductor seleccionado'),
                  ),
                ),
                TextButton(
                  onPressed: _createDriver,
                  child: const Text('Registrar nuevo conductor'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
