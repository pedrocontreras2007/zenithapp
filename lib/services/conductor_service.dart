import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conductor_model.dart';

class ConductorService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('conductores');

  Future<void> registrar(Conductor conductor) {
    return _collection.add(conductor.toMap());
  }

  Future<void> actualizar(Conductor conductor) {
    return _collection.doc(conductor.id).update(conductor.toMap());
  }

  Stream<List<Conductor>> obtenerConductores() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Conductor.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<Conductor?> obtenerConductorPorId(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Conductor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
