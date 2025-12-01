import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mantenimiento_model.dart';

class MantenimientoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('mantenimientos');

  Future<void> registrar(Mantenimiento mantenimiento) {
    return _collection.add(mantenimiento.toMap());
  }

  Future<void> actualizar(Mantenimiento mantenimiento) {
    return _collection.doc(mantenimiento.id).update(mantenimiento.toMap());
  }

  Future<void> eliminar(String id) {
    return _collection.doc(id).delete();
  }

  Stream<List<Mantenimiento>> porVehiculo(String vehiculoId) {
    return _collection
        .where('vehiculoId', isEqualTo: vehiculoId)
        .orderBy('fechaProgramada')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mantenimiento.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }
}
