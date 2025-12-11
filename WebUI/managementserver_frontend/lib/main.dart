import 'package:flutter/material.dart';
import 'theme.dart';

import 'package:provider/provider.dart';
import 'viewmodels/world_list_viewmodel.dart';
import 'provider/user_provider.dart';
import 'provider/servernode_provider.dart';
import 'layout/main_layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final userProvider = UserProvider();

  userProvider.setUser(User(
    username: 'MaxMustermann',
    role: 'Admin',
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => ServerNodeProvider()),
        ChangeNotifierProvider(create: (_) => WorldListViewModel(userProvider : userProvider)),
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
