import 'package:flutter/material.dart';
import '../models/world.dart';

enum WorldOverlay { none, create, edit, delete, import }

class WorldListViewModel extends ChangeNotifier {
  // -------------------------------
  // User information (set when logging in)
  // -------------------------------
  String username = "Guest";
  String role = "User";

  // -------------------------------
  // Worlds list
  // -------------------------------
  final List<World> _worlds = [];
  List<World> get worlds => _worlds;

  // -------------------------------
  // Overlay state
  // -------------------------------
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
    required String creatorname,
    required String worldMode,
  }) {
    final newWorld = World(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      worldname: worldname,
      creatorname: creatorname,
      worldMode: worldMode,
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

  // Import (example: adds a new world automatically)
  Future<void> importWorld() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final imported = World(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      worldname: "Imported World",
      creatorname: "Importer",
      worldMode: "Survival",
    );

    _worlds.add(imported);
    notifyListeners();
  }
}
