class Mantenimiento {
  final String id;
  final String vehiculoId;
  final String tipo; // preventivo o correctivo
  final DateTime fechaProgramada;
  final DateTime? fechaRealizada;
  final String observaciones;
  final String tecnico;
  final String estado; // Programado, Completado, Vencido

  Mantenimiento({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.fechaProgramada,
    this.fechaRealizada,
    this.observaciones = '',
    this.tecnico = '',
    this.estado = 'Programado',
  });

  bool get estaVencido {
    if (estado == 'Completado') return false;
    return fechaProgramada.isBefore(DateTime.now());
  }

  factory Mantenimiento.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime parseFecha(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is Map && value['seconds'] != null) {
        final seconds = value['seconds'];
        if (seconds is int) {
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }
      }
      return DateTime.now();
    }

    return Mantenimiento(
      id: documentId,
      vehiculoId: data['vehiculoId'] ?? '',
      tipo: data['tipo'] ?? 'Preventivo',
      fechaProgramada: parseFecha(data['fechaProgramada']),
      fechaRealizada:
          data['fechaRealizada'] != null ? parseFecha(data['fechaRealizada']) : null,
      observaciones: data['observaciones'] ?? '',
      tecnico: data['tecnico'] ?? '',
      estado: data['estado'] ?? 'Programado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehiculoId': vehiculoId,
      'tipo': tipo,
      'fechaProgramada': fechaProgramada.toIso8601String(),
      'fechaRealizada': fechaRealizada?.toIso8601String(),
      'observaciones': observaciones,
      'tecnico': tecnico,
      'estado': estado,
    };
  }
}
