import 'package:flutter/material.dart';
import '../models/world.dart';
import '../API/API_UIData.dart';

class ServerWorldListViewModel extends ChangeNotifier {
  final UiApiService apiService;

  ServerWorldListViewModel({
    required this.apiService,
  });

  List<World> _worlds = [];
  List<World> get worlds => _worlds;

  bool isLoading = false;

  Future<void> loadWorldsByNode(String nodeId) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      _worlds = await apiService.getWorldsByNode(nodeId);
    } catch (e) {
      debugPrint('Failed to load worlds for node $nodeId: $e');
      _worlds = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteWorld(String worldId) async {
    final success = await apiService.deleteWorld(worldId);

    if (success) {
      _worlds.removeWhere((w) => w.id == worldId);
      notifyListeners();
    }

    return success;
  }
}
