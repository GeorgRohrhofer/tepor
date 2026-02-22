import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../API/API_UIData.dart';
import '../widgets/sidebar.dart';
import '../Pages/world_list_page.dart';
import '../Pages/servernode_list_page.dart';
import '../Pages/settings_page.dart';

import 'dart:html' as html;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const WorldListPage(),
      // Use the instance of ServerNodeListViewModel from MultiProvider in main.dart
      const ServerNodeListPage(),
      const SettingsPage(),
    ];

    void onSelectIndex(int index) => setState(() => selectedIndex = index);
    void onSettings() => setState(() => selectedIndex = 2);

    void onLogout() {
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
                // Logout logic
                // _keycloak.logout();
                html.window.sessionStorage.clear();
                Restart.restartApp();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onSelectIndex: onSelectIndex,
            onSettings: onSettings,
            onLogout: onLogout,
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
