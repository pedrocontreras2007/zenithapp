import 'package:flutter/material.dart';
import '../models/mantenimiento_model.dart';
import '../models/vehiculo_model.dart';
import '../services/mantenimiento_service.dart';
import '../services/firestore_service.dart';

class AddEditMantenimientoScreen extends StatefulWidget {
  final Vehiculo vehiculo;
  final Mantenimiento? mantenimiento;

  const AddEditMantenimientoScreen({super.key, required this.vehiculo, this.mantenimiento});

  @override
  State<AddEditMantenimientoScreen> createState() => _AddEditMantenimientoScreenState();
}

class _AddEditMantenimientoScreenState extends State<AddEditMantenimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MantenimientoService();
  final _vehiculoService = FirestoreService();

  DateTime _fechaProgramada = DateTime.now();
  DateTime? _fechaRealizada;
  String _tipo = 'Preventivo';
  final _observacionesController = TextEditingController();
  final _tecnicoController = TextEditingController();
  String _estado = 'Programado';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final mantenimiento = widget.mantenimiento;
    if (mantenimiento != null) {
      _fechaProgramada = mantenimiento.fechaProgramada;
      _fechaRealizada = mantenimiento.fechaRealizada;
      _tipo = mantenimiento.tipo;
      _observacionesController.text = mantenimiento.observaciones;
      _tecnicoController.text = mantenimiento.tecnico;
      _estado = mantenimiento.estado;
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _tecnicoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    var guardado = false;

    final newMantenimiento = Mantenimiento(
      id: widget.mantenimiento?.id ?? '',
      vehiculoId: widget.vehiculo.id,
      tipo: _tipo,
      fechaProgramada: _fechaProgramada,
      fechaRealizada: _fechaRealizada,
      observaciones: _observacionesController.text.trim(),
      tecnico: _tecnicoController.text.trim(),
      estado: _estado,
    );

    try {
      if (widget.mantenimiento == null) {
        await _service.registrar(newMantenimiento);
      } else {
        await _service.actualizar(newMantenimiento);
      }

      // Si es mantenimiento futuro actualizamos la alerta del vehículo
      if (_estado != 'Completado') {
        await _vehiculoService.actualizarProximoMantenimiento(
          vehiculoId: widget.vehiculo.id,
          fecha: _fechaProgramada,
          tecnico: _tecnicoController.text.trim(),
        );
      }
      guardado = true;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar mantenimiento: $e')),
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

  Future<void> _seleccionarFechaProgramada() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaProgramada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fechaProgramada = picked);
    }
  }

  Future<void> _seleccionarFechaRealizada() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaRealizada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fechaRealizada = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mantenimiento == null ? 'Nuevo mantenimiento' : 'Editar mantenimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de mantenimiento'),
                items: const [
                  DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                  DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
                ],
                onChanged: (value) => setState(() => _tipo = value ?? 'Preventivo'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha programada'),
                subtitle: Text(
                  '${_fechaProgramada.day.toString().padLeft(2, '0')}/'
                  '${_fechaProgramada.month.toString().padLeft(2, '0')}/'
                  '${_fechaProgramada.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _seleccionarFechaProgramada,
                ),
              ),
              SwitchListTile(
                title: const Text('¿Mantenimiento completado?'),
                value: _estado == 'Completado',
                onChanged: (value) {
                  setState(() {
                    _estado = value ? 'Completado' : 'Programado';
                    if (value && _fechaRealizada == null) {
                      _fechaRealizada = DateTime.now();
                    }
                  });
                },
              ),
              if (_estado == 'Completado')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha realizada'),
                  subtitle: Text(
                    _fechaRealizada == null
                        ? 'Selecciona la fecha'
                        : '${_fechaRealizada!.day.toString().padLeft(2, '0')}/'
                            '${_fechaRealizada!.month.toString().padLeft(2, '0')}/'
                            '${_fechaRealizada!.year}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _seleccionarFechaRealizada,
                  ),
                ),
              TextFormField(
                controller: _tecnicoController,
                decoration: const InputDecoration(labelText: 'Técnico responsable'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar mantenimiento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
