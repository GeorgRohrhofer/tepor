import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/world.dart';
import '../models/servernode.dart';
import '../models/user.dart';

class UiApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';
  final String authUrl = dotenv.env['AUTH_URL'] ?? '';
  final String clientId = dotenv.env['CLIENT_ID'] ?? '';
  final String clientUsername = dotenv.env['CLIENT_USERNAME'] ?? '';
  final String clientPassword = dotenv.env['CLIENT_PASSWORD'] ?? '';

  String? _token;

  String? get token => _token;

  /// Authenticate via Keycloak and store Bearer token
  Future<bool> authenticate() async {
    final body = {
      'grant_type': 'password',
      'client_id': clientId,
      'username': clientUsername,
      'password': clientPassword,
    };

    final response = await http.post(
      Uri.parse(authUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _token = json['access_token'];
      return true;
    }
    return false;
  }

  Map<String, String> _authHeaders({Map<String, String>? extraHeaders}) {
    final headers = {'Authorization': 'Bearer $_token'};
    if (extraHeaders != null) headers.addAll(extraHeaders);
    return headers;
  }

  Future<User?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/UiApi/GetUserName');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return User.fromJson(jsonMap);
    }
    return null;
  }

  Future<List<String>> getRoles() async {
    final url = Uri.parse('$baseUrl/UiApi/GetRoles');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<ServerNode>> getNodes() async {
    final url = Uri.parse('$baseUrl/UiApi/GetNodes');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => ServerNode.fromJson(json)).toList();
    }
    return [];
  }

  Future<ServerNode?> getNode(String nodeId) async {
    final url = Uri.parse('$baseUrl/UiApi/GetNode');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'nodeId': nodeId}));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ServerNode.fromJson(jsonMap);
    }
    return null;
  }

  Future<List<World>> getWorldsByCurrentUser() async {
    final url = Uri.parse('$baseUrl/UiApi/GetWorldsByCurrentUser');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => World.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<World>> getWorldsByNode(String nodeId) async {
    final url = Uri.parse('$baseUrl/UiApi/GetWorldsByNode');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'nodeId': nodeId}));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => World.fromJson(json)).toList();
    }
    return [];
  }

  Future<World?> getWorld(String worldId) async {
    final url = Uri.parse('$baseUrl/UiApi/GetWorld');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'worldId': worldId}));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return World.fromJson(jsonMap);
    }
    return null;
  }

  Future<bool> createWorld(String worldName, String worldConfig) async {
    final url = Uri.parse('$baseUrl/UiApi/CreateWorld');
    final body = jsonEncode({'worldName': worldName, 'worldConfig': worldConfig});

    final response = await http.post(
      url,
      headers: _authHeaders(extraHeaders: {'Content-Type': 'application/json'}),
      body: body,
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteWorld(String worldId) async {
    final url = Uri.parse('$baseUrl/UiApi/DeleteWorld');
    final response = await http.delete(url, headers: _authHeaders(extraHeaders: {'worldId': worldId}));

    return response.statusCode == 200;
  }

  Future<bool> isBackendAlive() async {
    final url = Uri.parse('$baseUrl/UiApi/BackEndAlive');
    final response = await http.get(url, headers: _authHeaders());

    return response.statusCode == 200;
  }
}
