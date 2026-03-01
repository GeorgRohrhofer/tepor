import 'package:flutter/material.dart';
import 'package:managementserver_frontend/Keycloak/keycloak_web_service.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import 'theme.dart';
import 'layout/main_layout.dart';

import 'API/API_UIData.dart';
import 'ViewModels/world_list_viewmodel.dart';
import 'ViewModels/servernode_list_viewmodel.dart';
import 'ViewModels/settings_viewmodel.dart';

import 'provider/user_provider.dart';

import 'models/user.dart';

void main() async {
  final KeycloakWebService _keycloak = KeycloakWebService();
  var isAuthenticated = false;
  var accessToken = "";


  final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters.containsKey('code')) {
    try {
      final tokens = await _keycloak.handleCallback();
      if (tokens != null) {
        print('Login erfolgreich!');
        accessToken = tokens['access_token'];
      }
    } catch (e) {
      print('Callback Fehler: $e');
    }
  }

  isAuthenticated = _keycloak.isAuthenticated();

  if (!isAuthenticated) {
    _keycloak.login();
    return;
  }

  if (accessToken.isEmpty) {
    accessToken = _keycloak.getAccessToken() ?? "";
  }

  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  
  const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3333');

  final uiApiService = UiApiService(accessToken, apiUrl);
  var currentUserName = await uiApiService.getCurrentUserName();
  var currentUserRoles = await uiApiService.getRoles();
  userProvider.setUser(
    User(
      username: currentUserName,
      role: currentUserRoles.last
      ),
  );


  runApp(
      Provider<UiApiService>.value(
        value: uiApiService,
        child: MultiProvider(
          providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider(
            create: (_) => ServerNodeListViewModel(apiService: uiApiService),
            ),
          ChangeNotifierProvider(
            create: (_) => WorldListViewModel(
              apiService: uiApiService,
              userProvider: userProvider,
              ),
            ),
          ChangeNotifierProvider(
            create: (_) => DiscordSettingsViewModel(apiService: uiApiService),
            )
          ],
          child: const MyApp(),
          ),
        ),
        );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData().textTheme);

    return MaterialApp(
      title: 'Management Server',
      theme: materialTheme.light(),
      home: const MainLayout(),
    );
  }
}
