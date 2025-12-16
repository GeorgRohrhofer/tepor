import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme.dart';
import 'layout/main_layout.dart';

import 'api/API_UIDATA.dart';
import 'viewmodels/world_list_viewmodel.dart';
import 'viewmodels/servernode_list_viewmodel.dart';

import 'provider/user_provider.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // ───────── Providers ─────────
  final userProvider = UserProvider();

  // Mock user (replace later with auth)
  userProvider.setUser(
    User(
      username: 'MaxMustermann',
      role: 'Admin',
    ),
  );

  // API service (singleton-style)
  final uiApiService = UiApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),

        // ServerNodeListViewModel Provider
        ChangeNotifierProvider(
          create: (_) => ServerNodeListViewModel(apiService: uiApiService),
        ),

        // WorldListViewModel Provider
        ChangeNotifierProvider(
          create: (_) => WorldListViewModel(
            apiService: uiApiService,
            userProvider: userProvider,
          ),
        ),
      ],
      child: const MyApp(),
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
