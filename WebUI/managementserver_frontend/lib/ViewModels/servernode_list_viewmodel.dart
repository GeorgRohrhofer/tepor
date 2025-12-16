import 'package:flutter/material.dart';
import '../api/API_UIDATA.dart';
import '../models/servernode.dart';

class ServerNodeListViewModel extends ChangeNotifier {
  final UiApiService apiService;

  ServerNodeListViewModel({required this.apiService});

  List<ServerNode> _servernodes = [];
  List<ServerNode> get servernodes => _servernodes;

  bool isLoading = false;

  /// Holt die ServerNodes von der API über UiApiService
  Future<void> fetchServernodes() async {
    isLoading = true;
    notifyListeners();

    try {
      // Stelle sicher, dass der Token vorhanden ist
      if (apiService.token == null) {
        final authenticated = await apiService.authenticate();
        if (!authenticated) throw Exception("Authentication failed");
      }

      _servernodes = await apiService.getNodes();
    } catch (e) {
      _servernodes = [];
      debugPrint('Error fetching server nodes: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
