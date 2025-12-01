import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehiculo_model.dart';

class FirestoreService {
  final CollectionReference _vehiculosCollection =
      FirebaseFirestore.instance.collection('vehiculos');

  Future<void> agregarVehiculo(Vehiculo vehiculo) {
    return _vehiculosCollection.add(vehiculo.toMap());
  }

  Stream<List<Vehiculo>> getVehiculos() {
    return _vehiculosCollection.orderBy('matricula').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Vehiculo.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<Vehiculo> getVehiculo(String id) {
    return _vehiculosCollection.doc(id).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return Vehiculo(
          id: doc.id,
          matricula: '',
          marca: '',
          modelo: '',
          anio: 0,
          kilometraje: 0,
          estado: 'Sin datos',
        );
      }
      return Vehiculo.fromMap(data, doc.id);
    });
  }

  Future<void> actualizarVehiculo(Vehiculo vehiculo) {
    return _vehiculosCollection.doc(vehiculo.id).update(vehiculo.toMap());
  }

  Future<void> actualizarCamposVehiculo(
      String vehiculoId, Map<String, dynamic> data) {
    return _vehiculosCollection.doc(vehiculoId).update(data);
  }

  Future<void> eliminarVehiculo(String id) {
    return _vehiculosCollection.doc(id).delete();
  }

  Future<void> actualizarProximoMantenimiento({
    required String vehiculoId,
    required DateTime fecha,
    String tecnico = '',
  }) {
    return _vehiculosCollection.doc(vehiculoId).update({
      'proximoMantenimiento': fecha.toIso8601String(),
      'tecnicoAsignado': tecnico,
    });
  }
}