import 'package:flutter/material.dart';
import '../models/servernode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerNodeProvider extends ChangeNotifier {
  List<ServerNode> _servernodes = [];

  List<ServerNode> get servernodes => _servernodes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Daten von der API laden
  Future<void> loadServerNodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiUrl = dotenv.env['SERVERNODE_API_URL'] ?? '';
      if (apiUrl.isEmpty) throw Exception("SERVERNODE_API_URL ist nicht gesetzt!");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _servernodes = data.map((json) => ServerNode.fromJson(json)).toList();
      } else {
        _servernodes = [];
        debugPrint('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      _servernodes = [];
      debugPrint('Fehler beim Laden der ServerNodes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Optional: einzelne ServerNode hinzufügen
  void addServerNode(ServerNode node) {
    _servernodes.add(node);
    notifyListeners();
  }

  /// Optional: ServerNode löschen
  void removeServerNode(String id) {
    _servernodes.removeWhere((node) => node.id == id);
    notifyListeners();
  }
}
