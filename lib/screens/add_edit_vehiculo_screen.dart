import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/firestore_service.dart';

class AddEditVehiculoScreen extends StatefulWidget {
  final Vehiculo? vehiculo; // Si es null, estamos CREANDO. Si tiene datos, estamos EDITANDO.

  const AddEditVehiculoScreen({super.key, this.vehiculo});

  @override
  State<AddEditVehiculoScreen> createState() => _AddEditVehiculoScreenState();
}

class _AddEditVehiculoScreenState extends State<AddEditVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controladores para los campos de texto
  final _matriculaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _tecnicoController = TextEditingController();
  
  String _estadoSeleccionado = 'Operativo';
  final List<String> _estados = ['Operativo', 'En Taller', 'Baja'];
  DateTime? _proximoMantenimiento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si recibimos un vehículo, rellenamos los campos (Modo Edición)
    if (widget.vehiculo != null) {
      _matriculaController.text = widget.vehiculo!.matricula;
      _marcaController.text = widget.vehiculo!.marca;
      _modeloController.text = widget.vehiculo!.modelo;
      _anioController.text = widget.vehiculo!.anio.toString();
      _kilometrajeController.text = widget.vehiculo!.kilometraje.toString();
      _estadoSeleccionado = widget.vehiculo!.estado;
      _proximoMantenimiento = widget.vehiculo!.proximoMantenimiento;
      _tecnicoController.text = widget.vehiculo!.tecnicoAsignado;
    }
  }

  @override
  void dispose() {
    // Limpiamos memoria
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _kilometrajeController.dispose();
    _tecnicoController.dispose();
    super.dispose();
  }

  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    var vehiculoGuardado = false;

    final nuevoVehiculo = Vehiculo(
      id: widget.vehiculo?.id ?? '', // Si edita conserva ID, si crea es temporal
      matricula: _matriculaController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      anio: int.parse(_anioController.text.trim()),
      kilometraje: int.parse(_kilometrajeController.text.trim()),
      estado: _estadoSeleccionado,
      proximoMantenimiento: _proximoMantenimiento,
      tecnicoAsignado: _tecnicoController.text.trim(),
      conductorAsignadoId: widget.vehiculo?.conductorAsignadoId ?? '',
    );

    try {
      debugPrint('[Vehículo] Paso 1 -> ${widget.vehiculo == null ? 'creando' : 'actualizando'} ${nuevoVehiculo.matricula}');
      if (widget.vehiculo == null) {
        await _firestoreService.agregarVehiculo(nuevoVehiculo);
      } else {
        await _firestoreService.actualizarVehiculo(nuevoVehiculo);
      }
      vehiculoGuardado = true;
      debugPrint('[Vehículo] Paso 1 completado');
    } catch (e, st) {
      debugPrint('[Vehículo] Error al guardar: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (vehiculoGuardado) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehiculo == null ? 'Nuevo Vehículo' : 'Editar Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula (Patente)'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marcaController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _modeloController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _anioController,
                      decoration: const InputDecoration(labelText: 'Año'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _kilometrajeController,
                      decoration: const InputDecoration(labelText: 'Kilometraje'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tecnicoController,
                decoration: const InputDecoration(labelText: 'Técnico responsable'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _proximoMantenimiento == null
                          ? 'Sin próxima mantención programada'
                          : 'Próxima mantención: '
                              '${_proximoMantenimiento!.day.toString().padLeft(2, '0')}/'
                              '${_proximoMantenimiento!.month.toString().padLeft(2, '0')}/'
                              '${_proximoMantenimiento!.year}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _proximoMantenimiento ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _proximoMantenimiento = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Programar mantención'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _estadoSeleccionado,
                decoration: const InputDecoration(labelText: 'Estado Actual'),
                items: _estados.map((String estado) {
                  return DropdownMenuItem(value: estado, child: Text(estado));
                }).toList(),
                onChanged: (val) => setState(() => _estadoSeleccionado = val!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarVehiculo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('GUARDAR VEHÍCULO', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}