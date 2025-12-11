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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 250,
      color: colors.surfaceContainer,
      child: Column(
        children: [
          const SizedBox(height: 50),

          // Main navigation
          ListTile(
            selected: selectedIndex == 0,
            leading: Icon(Icons.public, color: colors.onSurface),
            title: Text('Worlds', style: TextStyle(color: colors.onSurface)),
            onTap: () => onSelectIndex(0),
          ),
          ListTile(
            selected: selectedIndex == 1,
            leading: Icon(Icons.storage, color: colors.onSurface),
            title: Text('Servernodes', style: TextStyle(color: colors.onSurface)),
            onTap: () => onSelectIndex(1),
          ),

          const Spacer(),

          // Settings Button
          ListTile(
            leading: Icon(Icons.settings, color: colors.primary),
            title: Text(
              'Settings',
              style: TextStyle(color: colors.primary),
            ),
            onTap: onSettings,
          ),

          // Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: colors.error),
            title: Text(
              'Logout',
              style: TextStyle(color: colors.error),
            ),
            onTap: onLogout,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
