import 'package:flutter/material.dart';
import '../models/world.dart';
import '../API/API_UIData.dart';
import '../provider/user_provider.dart';

enum WorldOverlay { none, create, edit, delete }

class WorldListViewModel extends ChangeNotifier {
  final UiApiService apiService;
  final UserProvider userProvider;

  WorldListViewModel({
    required this.apiService,
    required this.userProvider,
  });

  List<World> _worlds = [];
  List<World> get worlds => _worlds;
  bool _worldsSet = false;
  bool get worldsSet => _worldsSet;

  WorldOverlay activeOverlay = WorldOverlay.none;
  World? selectedWorld;

  bool isLoading = false;

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

  /// Lade Welten für den aktuellen User
  Future<void> loadWorlds() async {
    isLoading = true;
    notifyListeners();

    _worlds = await apiService.getWorldsByCurrentUser();
    _worldsSet = true;

    isLoading = false;
    notifyListeners();
  }

  /// Erstelle neue Welt
  Future<bool> createWorld({
    required String worldname,
    required String configString
  }) async {
    print(configString);
    final success = await apiService.createWorld(
      worldname,
      configString
    );
    if (success) {
      await loadWorlds();
    }
    return success;
  }

  /// Update Welt lokal (Backend API noch nicht implementiert)
  void updateWorld({
    required String id,
    required String worldname,
    required String creatorname,
    String? worldMode,
  }) {
    final world = _worlds.firstWhere((w) => w.id == id);
    world.worldname = worldname;
    world.creatorname = creatorname;
    if (worldMode != null) world.worldMode = worldMode;
    notifyListeners();
  }

  /// Lösche Welt
  Future<bool> deleteWorld(String worldId) async {
    final success = await apiService.deleteWorld(worldId);
    if (success) {
      _worlds.removeWhere((w) => w.id == worldId);
      notifyListeners();
    }
    return success;
  }
}
