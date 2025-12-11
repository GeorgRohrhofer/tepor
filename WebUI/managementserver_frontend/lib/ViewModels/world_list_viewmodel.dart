import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/world.dart';
import '../provider/user_provider.dart';

enum WorldOverlay { none, create, edit, delete }

class WorldListViewModel extends ChangeNotifier {
  final UserProvider userProvider; // ← direkt

  WorldListViewModel({required this.userProvider});

  final List<World> _worlds = [];
  List<World> get worlds => _worlds;

  WorldOverlay activeOverlay = WorldOverlay.none;
  World? selectedWorld;

  void showOverlay(WorldOverlay overlay, [World? world]) {
    activeOverlay = overlay;
    selectedWorld = world;
    notifyListeners();
  }

  void closeOverlay() {
    activeOverlay = WorldOverlay.none;
    selectedWorld = null;
    notifyListeners();
  }

  // -------------------------------
  // CRUD Operations
  // -------------------------------

  // Create
  void createWorld({
    required String worldname,
    required String worldMode,
    required String worldSeed,
    required BuildContext context,
  }) {
    final username = context.read<UserProvider>().username;

    final newWorld = World(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      worldname: worldname,
      creatorname: username,
      worldMode: worldMode,
      worldSeed: worldSeed,
    );

    _worlds.add(newWorld);
    notifyListeners();
  }

  // Update (mutates the existing object)
  void updateWorld({
    required String id,
    required String worldname,
    required String creatorname,
    String? worldMode,
  }) {
    final world = _worlds.firstWhere(
      (w) => w.id == id,
      orElse: () => throw Exception("World not found"),
    );

    // Mutate fields directly
    world.worldname = worldname;
    world.creatorname = creatorname;
    if (worldMode != null) world.worldMode = worldMode;

    notifyListeners(); // tell Flutter to rebuild UI
  }

  // Delete
  void deleteWorld(String id) {
    _worlds.removeWhere((w) => w.id == id);
    notifyListeners();
  }

}
