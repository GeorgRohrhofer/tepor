import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/world_list_viewmodel.dart';
import 'provider/user_provider.dart';
import 'layout/main_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
    child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorldListViewModel(),
      child: MaterialApp(
        title: 'World Manager',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainLayout(),
      ),
    );
  }
}
