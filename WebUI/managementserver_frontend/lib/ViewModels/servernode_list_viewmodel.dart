import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/servernode.dart';

class ServernodeListViewModel extends ChangeNotifier {
  List<ServerNode> _servernodes = [];
  bool isLoading = false;

  List<ServerNode> get servernodes => _servernodes;

  Future<void> fetchServernodes() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://your-backend.com/servernodes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _servernodes = data.map((json) => ServerNode(
            id: json['id'],
            cpu: json['cpu'],
            ram: json['ram'],
            network: json['networkUsage'],
            disk: json['diskUsage'],
            worlds: json['worlds']
          )).toList();
    } else {
      _servernodes = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
