import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recurso_consumo_model.dart';

class RecursoService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('recursos');

  Future<void> registrar(RecursoConsumo registro) {
    return _collection.add(registro.toMap());
  }

  Stream<List<RecursoConsumo>> porVehiculo(String vehiculoId) {
    return _collection
        .where('vehiculoId', isEqualTo: vehiculoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecursoConsumo.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }
}
