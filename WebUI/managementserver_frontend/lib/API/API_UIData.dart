import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/world.dart';
import '../models/servernode.dart';
import '../models/user.dart';
import '../Keycloak/keycloak_web_service.dart';

class UiApiService {
  UiApiService._privateConstructor() 
    : baseUrl = dotenv.env['API_URL'] ?? '';
  
  static final UiApiService _instance = UiApiService._privateConstructor();
  
  factory UiApiService() 
  {
    return _instance;
  }

  final String baseUrl;

  static String? _token;

  // UiApiService()
  //     : baseUrl = dotenv.env['API_URL'] ?? ''
  // {
  //   if (baseUrl.isEmpty) {
  //     throw Exception("API_URL sind nicht gesetzt in .env!");
  //   }
  // }

  String? get token => _token;

  void setToken(String token) => _token = token;

  /// Authenticate via Keycloak and store Bearer token
  // Future<bool> authenticate() async {
  //   debugPrint("Authenticating with $authUrl ...");
  //   final body = {
  //     'grant_type': 'password',
  //     'client_id': clientId,
  //     'username': clientUsername,
  //     'password': clientPassword,
  //   };
  //
  //   final response = await http.post(
  //     Uri.parse(authUrl),
  //     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //     body: body,
  //   );
  //
  //   debugPrint('Auth Response: ${response.statusCode} ${response.body}');
  //
  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //     _token = json['access_token'];
  //     debugPrint('Authenticated successfully. Token: $_token');
  //     return true;
  //   }
  //
  //   debugPrint('Authentication failed!');
  //   return false;
  // }

  Map<String, String> _authHeaders({Map<String, String>? extraHeaders}) {
    if (_token == null) {
      _token = KeycloakWebService().getAccessToken();
      // throw Exception("Token ist null. Bitte authenticate() vorher aufrufen!");
    }
    final headers = {'Authorization': 'Bearer $_token'};
    if (extraHeaders != null) headers.addAll(extraHeaders);

    print(_token);
    return headers;
  }

  Future<User?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/UiApi/GetUserName');
    debugPrint('GET $url');
    final response = await http.get(url, headers: _authHeaders());
    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<String>> getRoles() async {
    final url = Uri.parse('$baseUrl/UiApi/GetRoles');
    debugPrint('GET $url');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<ServerNode>> getNodes() async {
    final url = Uri.parse('$baseUrl/UiApi/GetNodes');
    debugPrint('GET $url');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => ServerNode.fromJson(json)).toList();
    }
    return [];
  }

  Future<ServerNode?> getNode(String nodeId) async {
    if (nodeId.isEmpty) throw Exception("nodeId darf nicht leer sein");
    final url = Uri.parse('$baseUrl/UiApi/GetNode');
    debugPrint('GET $url with nodeId=$nodeId');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'nodeId': nodeId}));

    if (response.statusCode == 200) {
      return ServerNode.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<World>> getWorldsByCurrentUser() async {
    final url = Uri.parse('$baseUrl/UiApi/GetWorldsByCurrentUser');
    debugPrint('GET $url');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).map((json) => World.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<World>> getWorldsByNode(String nodeId) async {
    if (nodeId.isEmpty) throw Exception("nodeId darf nicht leer sein");
    final url = Uri.parse('$baseUrl/UiApi/GetWorldsByNode');
    debugPrint('GET $url with nodeId=$nodeId');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'nodeId': nodeId}));

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).map((json) => World.fromJson(json)).toList();
    }
    return [];
  }

  Future<World?> getWorld(String worldId) async {
    if (worldId.isEmpty) throw Exception("worldId darf nicht leer sein");
    final url = Uri.parse('$baseUrl/UiApi/GetWorld');
    debugPrint('GET $url with worldId=$worldId');
    final response = await http.get(url, headers: _authHeaders(extraHeaders: {'worldId': worldId}));

    if (response.statusCode == 200) {
      return World.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> createWorld(String worldName, String worldConfig) async {
    if (worldName.isEmpty || worldConfig.isEmpty) throw Exception("worldName und worldConfig dürfen nicht leer sein");
    final url = Uri.parse('$baseUrl/UiApi/CreateWorld');
    debugPrint('POST $url with body=$worldName / $worldConfig');
    final body = jsonEncode({'worldName': worldName, 'worldConfig': worldConfig});

    final response = await http.post(
      url,
      headers: _authHeaders(extraHeaders: {'Content-Type': 'application/json'}),
      body: body,
    );

    debugPrint('Response: ${response.statusCode} ${response.body}');
    return response.statusCode == 200;
  }

  Future<bool> deleteWorld(String worldId) async {
    if (worldId.isEmpty) throw Exception("worldId darf nicht leer sein");
    final url = Uri.parse('$baseUrl/UiApi/DeleteWorld');
    debugPrint('DELETE $url with worldId=$worldId');

    final response = await http.delete(url, headers: _authHeaders(extraHeaders: {'worldId': worldId}));
    debugPrint('Response: ${response.statusCode} ${response.body}');

    return response.statusCode == 200;
  }

  Future<bool> isBackendAlive() async {
    final url = Uri.parse('$baseUrl/UiApi/BackEndAlive');
    debugPrint('GET $url');

    final response = await http.get(url, headers: _authHeaders());
    debugPrint('Response: ${response.statusCode}');

    return response.statusCode == 200;
  }

  Future<String?> getDiscordChatId() async {
    final url = Uri.parse('$baseUrl/UiApi/GetDiscordIDs');
    debugPrint('GET $url');

    final response = await http.get(url, headers: _authHeaders());
    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode != 200) {
      return null;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final ids = jsonList.cast<String>();
      return ids.join('\n');
    } catch (_) {
      // Fallback if backend returns plain text instead of JSON
      return response.body;
    }
  }

  Future<void> setDiscordIds(List<String> ids) async {
    final uri = Uri.parse('$baseUrl/UiApi/SetDiscordIDs');
    debugPrint('POST $uri | body=$ids');

    final resp = await http.post(
      uri,
      headers: _authHeaders(extraHeaders: {
        'Content-Type': 'application/json',
      }),
      body: jsonEncode(ids),
    );

    debugPrint('Response: ${resp.statusCode} ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to set Discord IDs: ${resp.statusCode}');
    }
  }
}
