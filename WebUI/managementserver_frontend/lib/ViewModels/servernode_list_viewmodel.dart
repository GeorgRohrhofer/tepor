import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/servernode.dart';

class ServerNodeListViewModel extends ChangeNotifier {
  List<ServerNode> _servernodes = [];
  bool isLoading = false;

  List<ServerNode> get servernodes => _servernodes;

  /// Holt die ServerNodes von der API
  Future<void> fetchServernodes() async {
    isLoading = true;
    notifyListeners();

    try {
      // API-URL aus .env laden
      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("API_URL not defined in .env");
      }

      final url = Uri.parse('$baseUrl/servernodes');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _servernodes =
            data.map((json) => ServerNode.fromJson(json)).toList();
      } else {
        _servernodes = [];
        debugPrint(
            'Failed to fetch server nodes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _servernodes = [];
      debugPrint('Error fetching server nodes: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
