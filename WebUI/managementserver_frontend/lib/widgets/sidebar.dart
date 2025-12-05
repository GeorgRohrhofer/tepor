import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 140, 226, 212),
      child: Column(
        children: [
          const SizedBox(height: 50),

          // Hauptnavigation
          ListTile(
            selected: selectedIndex == 0,
            leading: const Icon(Icons.public),
            title: const Text('Worlds'),
            onTap: () => onSelectIndex(0),
          ),
          ListTile(
            selected: selectedIndex == 1,
            leading: const Icon(Icons.storage),
            title: const Text('Servernodes'),
            onTap: () => onSelectIndex(1),
          ),

          const Spacer(), // Schiebt Buttons nach unten

          // Settings Button
          ListTile(
            leading: const Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Settings'),
            onTap: onSettings,
          ),
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Color.fromARGB(255, 8, 6, 5)),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
          const SizedBox(height: 20), // Optional: Abstand zum unteren Rand
        ],
      ),
    );
  }
}
