import 'package:flutter/material.dart';
import '../models/world.dart';
import '../API/API_UIDATA.dart';

enum WorldOverlay { none, create, edit, delete }

class ServerWorldListViewModel extends ChangeNotifier {
  final UiApiService apiService;

  ServerWorldListViewModel({
    required this.apiService,
  });

  List<World> _worlds = [];
  List<World> get worlds => _worlds;

  WorldOverlay activeOverlay = WorldOverlay.none;
  World? selectedWorld;

  bool isLoading = false;

  // -------------------------------
  // Overlay handling
  // -------------------------------

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
  // API – Worlds by Node
  // -------------------------------

  Future<void> loadWorldsByNode(String nodeId) async {
    isLoading = true;
    notifyListeners();

    _worlds = await apiService.getWorldsByNode(nodeId);

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------
  // Delete World
  // -------------------------------

  Future<bool> deleteWorld(String worldId) async {
    final success = await apiService.deleteWorld(worldId);

    if (success) {
      _worlds.removeWhere((w) => w.id == worldId);
      notifyListeners();
    }

    return success;
  }
}
