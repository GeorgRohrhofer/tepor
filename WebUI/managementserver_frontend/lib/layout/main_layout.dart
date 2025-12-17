import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../API/API_UIData.dart';
import '../widgets/sidebar.dart';
import '../Pages/world_list_page.dart';
import '../Pages/servernode_list_page.dart';
import '../Pages/settings_page.dart';

import '../Keycloak/keycloak_web_service.dart';
import 'dart:html' as html;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final KeycloakWebService _keycloak = KeycloakWebService();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters.containsKey('code')) {
      try {
        final tokens = await _keycloak.handleCallback();
        if (tokens != null) {
          print('Login erfolgreich!');
          context.watch<UiApiService>().setToken(tokens['access_token']);
        }
      } catch (e) {
        print('Callback Fehler: $e');
      }
    }

    setState(() {
      _isAuthenticated = _keycloak.isAuthenticated();
    });

    if (!_isAuthenticated) {
      _keycloak.login();
      context.watch<UiApiService>().setToken(_keycloak.getAccessToken() ?? "");
    }
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
                _keycloak.logout();
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
