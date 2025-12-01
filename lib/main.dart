import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  // Aseguramos que los widgets estén listos antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase con las opciones de tu proyecto Zenith
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _configureOfflinePersistence();

  runApp(const MainApp());
}

Future<void> _configureOfflinePersistence() async {
  try {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } catch (e) {
    debugPrint('No se pudo habilitar la persistencia offline: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zenith Transporte',
      home: HomeScreen(),
    );
  }
}