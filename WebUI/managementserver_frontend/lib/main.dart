import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme.dart';
import 'layout/main_layout.dart';

import 'API/API_UIData.dart';
import 'ViewModels/world_list_viewmodel.dart';
import 'ViewModels/servernode_list_viewmodel.dart';
import 'ViewModels/settings_viewmodel.dart';

import 'provider/user_provider.dart';

import 'models/user.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final userProvider = UserProvider();
  userProvider.setUser(
    User(username: 'MaxMustermann', role: 'Admin'),
  );

  final uiApiService = UiApiService();
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
