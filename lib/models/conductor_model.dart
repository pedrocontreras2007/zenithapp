class Conductor {
  final String id;
  final String nombre;
  final String telefono;
  final String licencia;
  final bool disponible;

  Conductor({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.licencia,
    this.disponible = true,
  });

  factory Conductor.fromMap(Map<String, dynamic> data, String documentId) {
    return Conductor(
      id: documentId,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      licencia: data['licencia'] ?? '',
      disponible: data['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'licencia': licencia,
      'disponible': disponible,
    };
  }
}
