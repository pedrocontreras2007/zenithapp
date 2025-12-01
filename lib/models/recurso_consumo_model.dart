class RecursoConsumo {
  final String id;
  final String vehiculoId;
  final String tipo; // combustible, repuesto, etc.
  final double cantidad;
  final String unidad;
  final DateTime fecha;
  final String observaciones;

  RecursoConsumo({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.fecha,
    this.observaciones = '',
  });

  factory RecursoConsumo.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime fecha = DateTime.now();
    final rawFecha = data['fecha'];
    if (rawFecha is String) {
      fecha = DateTime.tryParse(rawFecha) ?? fecha;
    } else if (rawFecha is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(rawFecha);
    } else if (rawFecha is Map && rawFecha['seconds'] != null) {
      final seconds = rawFecha['seconds'];
      if (seconds is int) {
        fecha = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    return RecursoConsumo(
      id: documentId,
      vehiculoId: data['vehiculoId'] ?? '',
      tipo: data['tipo'] ?? 'Consumo',
      cantidad: (data['cantidad'] ?? 0).toDouble(),
      unidad: data['unidad'] ?? 'u',
      fecha: fecha,
      observaciones: data['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehiculoId': vehiculoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'unidad': unidad,
      'fecha': fecha.toIso8601String(),
      'observaciones': observaciones,
    };
  }
}
