import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../pages/world_list_page.dart';
import '../pages/servernode_list_page.dart';
import '../pages/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final pages = [
    WorldListPage(),
    ServerNodeListPage(),
    SettingsPage(),
  ];

  void onSelectIndex(int index) {
    setState(() => selectedIndex = index);
  }

  void onSettings() {
    setState(() {
      selectedIndex = 2; // Index der SettingsPage im pages-Array
    });
  }

  void onLogout() {
    // Beispiel: Logout-Dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Willst du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Hier echte Logout-Logik einfügen
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onSelectIndex: onSelectIndex,
            onSettings: onSettings,
            onLogout: onLogout,
          ),
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}
