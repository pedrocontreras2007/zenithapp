class Vehiculo {
  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final int anio;
  final int kilometraje;
  final String estado; // Ejemplo: "Operativo", "En Taller", "Baja"
  final String imagenUrl; // Opcional
  final DateTime? proximoMantenimiento;
  final String tecnicoAsignado;
  final String conductorAsignadoId;

  Vehiculo({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.kilometraje,
    required this.estado,
    this.imagenUrl = '',
    this.proximoMantenimiento,
    this.tecnicoAsignado = '',
    this.conductorAsignadoId = '',
  });

  bool get requiereAlerta {
    if (proximoMantenimiento == null) return false;
    final hoy = DateTime.now();
    return proximoMantenimiento!.isBefore(hoy.add(const Duration(days: 7)));
  }

  factory Vehiculo.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime? proximo;
    final raw = data['proximoMantenimiento'];
    if (raw != null) {
      if (raw is DateTime) {
        proximo = raw;
      } else if (raw is String) {
        proximo = DateTime.tryParse(raw);
      } else if (raw is int) {
        proximo = DateTime.fromMillisecondsSinceEpoch(raw);
      } else if (raw is Map && raw['seconds'] != null) {
        final seconds = raw['seconds'];
        if (seconds is int) {
          proximo = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }
      }
    }

    return Vehiculo(
      id: documentId,
      matricula: data['matricula'] ?? '',
      marca: data['marca'] ?? '',
      modelo: data['modelo'] ?? '',
      anio: data['anio'] ?? 0,
      kilometraje: data['kilometraje'] ?? 0,
      estado: data['estado'] ?? 'Operativo',
      imagenUrl: data['imagenUrl'] ?? '',
      proximoMantenimiento: proximo,
      tecnicoAsignado: data['tecnicoAsignado'] ?? '',
      conductorAsignadoId: data['conductorAsignadoId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'kilometraje': kilometraje,
      'estado': estado,
      'imagenUrl': imagenUrl,
      'proximoMantenimiento': proximoMantenimiento?.toIso8601String(),
      'tecnicoAsignado': tecnicoAsignado,
      'conductorAsignadoId': conductorAsignadoId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      ...toMap(),
    };
  }
}