import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usuariosCollection =
      FirebaseFirestore.instance.collection('usuarios');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureUserDocument(credential.user);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<String?> roleStream(String uid) {
    return _usuariosCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return 'tecnico';
      return (doc.data() as Map<String, dynamic>)['rol'] as String? ?? 'tecnico';
    });
  }

  Future<void> _ensureUserDocument(User? user) async {
    if (user == null) return;
    final docRef = _usuariosCollection.doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'email': user.email,
        'rol': 'tecnico',
        'nombre': user.displayName ?? '',
        'creado': FieldValue.serverTimestamp(),
      });
    }
  }
}
