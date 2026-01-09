import 'package:flutter/material.dart';
import '../API/API_UIData.dart';
import '../models/servernode.dart';

class ServerNodeListViewModel extends ChangeNotifier {
  final UiApiService apiService;

  ServerNodeListViewModel({required this.apiService});

  List<ServerNode> servernodes = [];
  bool isLoading = false;
  bool _loadedOnce = false;

  Future<void> loadServernodes() async {
    if (_loadedOnce || isLoading) return;

    _loadedOnce = true;
    isLoading = true;
    notifyListeners();

    try {
      servernodes = await apiService.getNodes();
    } catch (e) {
      debugPrint('Error fetching server nodes: $e');
      servernodes = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
