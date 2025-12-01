import 'package:flutter/material.dart';
import '../models/recurso_consumo_model.dart';
import '../models/vehiculo_model.dart';
import '../services/recurso_service.dart';

class AddResourceLogScreen extends StatefulWidget {
  final Vehiculo vehiculo;
  const AddResourceLogScreen({super.key, required this.vehiculo});

  @override
  State<AddResourceLogScreen> createState() => _AddResourceLogScreenState();
}

class _AddResourceLogScreenState extends State<AddResourceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _unidadController = TextEditingController(text: 'L');
  final _observacionesController = TextEditingController();
  final _service = RecursoService();
  DateTime _fecha = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _tipoController.dispose();
    _cantidadController.dispose();
    _unidadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    var guardado = false;
    final registro = RecursoConsumo(
      id: '',
      vehiculoId: widget.vehiculo.id,
      tipo: _tipoController.text.trim(),
      cantidad: double.parse(_cantidadController.text.trim()),
      unidad: _unidadController.text.trim(),
      fecha: _fecha,
      observaciones: _observacionesController.text.trim(),
    );
    try {
      await _service.registrar(registro);
      guardado = true;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar recurso: $e')),
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

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar consumo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (combustible, repuesto...)'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obligatorio';
                        return double.tryParse(value) == null ? 'Ingresa un número válido' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _unidadController,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de registro'),
                subtitle: Text(
                  '${_fecha.day.toString().padLeft(2, '0')}/'
                  '${_fecha.month.toString().padLeft(2, '0')}/'
                  '${_fecha.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _seleccionarFecha,
                ),
              ),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                minLines: 2,
                maxLines: 4,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar consumo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
