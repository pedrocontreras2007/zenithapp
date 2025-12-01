import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Se guarda en el dispositivo'),
            value: themeController.isDarkMode,
            onChanged: (value) => themeController.toggleDarkMode(value),
          ),
        ],
      ),
    );
  }
}
