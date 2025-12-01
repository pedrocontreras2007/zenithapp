import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/theme_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';

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
    final authService = AuthService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeController(PreferencesService()),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          final themeMode = themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zenith Transporte',
            themeMode: themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: StreamBuilder<User?>(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return const LoginScreen();
                }

                return StreamBuilder<String?>(
                  stream: authService.roleStream(user.uid),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final role = roleSnapshot.data ?? 'tecnico';
                    return HomeScreen(userRole: role);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}