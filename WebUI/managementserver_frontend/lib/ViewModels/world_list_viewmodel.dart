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

    // API-Aufruf erst, wenn Token vorhanden
    if (apiService.token == null) {
      final authSuccess = await apiService.authenticate();
      if (!authSuccess) {
        debugPrint("Authentication failed!");
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    _worlds = await apiService.getWorldsByCurrentUser();

    isLoading = false;
    notifyListeners();
  }

  /// Erstelle neue Welt
  Future<bool> createWorld({
    required String worldname,
    required String worldMode,
    required String worldSeed,
  }) async {
    final success = await apiService.createWorld(worldname, worldSeed);
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
