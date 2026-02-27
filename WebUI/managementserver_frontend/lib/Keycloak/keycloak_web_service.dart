import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class KeycloakWebService {
  static const String keycloakUrl = 'https://tozm.net:8080';
  static const String realm = 'tepor-auth';
  static const String clientId = 'kekClient';
  Timer? _refreshTimer;

  static const String scopes = '';

  static String get redirectUrl => '${html.window.location.origin}/';

  static String get authorizationEndpoint =>
      '$keycloakUrl/realms/$realm/protocol/openid-connect/auth';

  static String get tokenEndpoint =>
      '$keycloakUrl/realms/$realm/protocol/openid-connect/token';

  static String get logoutEndpoint =>
      '$keycloakUrl/realms/$realm/protocol/openid-connect/logout';

  static String get userInfoEndpoint =>
      '$keycloakUrl/realms/$realm/protocol/openid-connect/userinfo';

  // PKCE Helper mit SHA-256
  String _generateCodeVerifier() {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = List.generate(
      128,
      (_) => charset[DateTime.now().microsecondsSinceEpoch % charset.length],
    );
    return random.join();
  }

  String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  // SHA-256 Code Challenge
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return _base64UrlEncode(digest.bytes);
  }

  String _generateState() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<Map<String, dynamic>> _httpPost(
    String url,
    Map<String, String> body,
  ) async {
    final request = html.HttpRequest();

    try {
      request.open('POST', url);
      request.setRequestHeader(
        'Content-Type',
        'application/x-www-form-urlencoded',
      );

      final bodyString = body.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      request.send(bodyString);

      await request.onLoadEnd.first;

      if (request.status == 200) {
        return json.decode(request.responseText!);
      } else {
        throw Exception('HTTP ${request.status}: ${request.responseText}');
      }
    } catch (e) {
      throw Exception('HTTP Request fehlgeschlagen: $e');
    }
  }

  Future<Map<String, dynamic>> _httpGet(
    String url, {
    String? bearerToken,
  }) async {
    final request = html.HttpRequest();

    try {
      request.open('GET', url);
      if (bearerToken != null) {
        request.setRequestHeader('Authorization', 'Bearer $bearerToken');
      }

      request.send();

      await request.onLoadEnd.first;

      if (request.status == 200) {
        return json.decode(request.responseText!);
      } else {
        throw Exception('HTTP ${request.status}: ${request.responseText}');
      }
    } catch (e) {
      throw Exception('HTTP Request fehlgeschlagen: $e');
    }
  }

  void login() {
    final state = _generateState();
    final codeVerifier = _generateCodeVerifier();

    html.window.sessionStorage['auth_state'] = state;
    html.window.sessionStorage['code_verifier'] = codeVerifier;

    final codeChallenge = _generateCodeChallenge(codeVerifier);

    print('=== Keycloak Login Debug ===');
    print('Keycloak URL: $keycloakUrl');
    print('Realm: $realm');
    print('Client ID: $clientId');
    print('Redirect URI: $redirectUrl');
    print('Code Challenge Method: S256 (SHA-256)');

    final queryParams = {
      'client_id': clientId,
      'redirect_uri': redirectUrl,
      'response_type': 'code',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256', // SHA-256!
      'prompt': 'login',
    };

    if (scopes.isNotEmpty) {
      queryParams['scope'] = scopes;
    }

    final authUrl = Uri.parse(
      authorizationEndpoint,
    ).replace(queryParameters: queryParams);

    // Redirect zu Keycloak
    html.window.location.href = authUrl.toString();
  }

  Future<Map<String, dynamic>?> handleCallback() async {
    final uri = Uri.parse(html.window.location.href);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];

    if (error != null) {
      print('Keycloak Fehler: $error');
      print('Beschreibung: $errorDescription');
      throw Exception('Keycloak Error: $error - $errorDescription');
    }

    if (code == null) return null;

    final savedState = html.window.sessionStorage['auth_state'];
    if (state != savedState) {
      throw Exception('State Mismatch');
    }

    final codeVerifier = html.window.sessionStorage['code_verifier'];
    if (codeVerifier == null) {
      throw Exception('Code Verifier nicht gefunden');
    }

    final tokens = await _httpPost(tokenEndpoint, {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'code': code,
      'redirect_uri': redirectUrl,
      'code_verifier': codeVerifier,
    });

    html.window.sessionStorage['access_token'] = tokens['access_token'];
    if (tokens['refresh_token'] != null) {
      html.window.sessionStorage['refresh_token'] = tokens['refresh_token'];
    }
    if (tokens['id_token'] != null) {
      html.window.sessionStorage['id_token'] = tokens['id_token'];
    }

    html.window.history.replaceState(null, '', '/');

    print(tokens['access_token']);

    _scheduleTokenRefresh(tokens['access_token']);

    return tokens;
  }

  String? getAccessToken() {
    return html.window.sessionStorage['access_token'];
  }

  Future<bool> refreshToken() async {
    final refreshToken = html.window.sessionStorage['refresh_token'];

    if (refreshToken == null) return false;

    try {
      final tokens = await _httpPost(tokenEndpoint, {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': refreshToken,
      });

      html.window.sessionStorage['access_token'] = tokens['access_token'];
      if (tokens['refresh_token'] != null) {
        html.window.sessionStorage['refresh_token'] = tokens['refresh_token'];
      }
      return true;
    } catch (e) {
      print('Refresh Token Fehler: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final accessToken = getAccessToken();

    if (accessToken == null) return null;

    try {
      return await _httpGet(userInfoEndpoint, bearerToken: accessToken);
    } catch (e) {
      print('User Info Fehler: $e');
      return null;
    }
  }

  bool isAuthenticated() {
    return getAccessToken() != null;
  }

  Future<void> logout() async {
    final idToken = html.window.sessionStorage['id_token'];

    html.window.sessionStorage.remove('access_token');
    html.window.sessionStorage.remove('refresh_token');
    html.window.sessionStorage.remove('id_token');
    html.window.sessionStorage.remove('auth_state');

    if (idToken != null) {
      final logoutUrl = Uri.parse(logoutEndpoint).replace(
        queryParameters: {
          'id_token_hint': idToken,
          'post_logout_redirect_uri': redirectUrl,
        },
      );

      html.window.location.href = logoutUrl.toString();
    } else {
      html.window.location.href = '/';
    }
  }

  Map<String, dynamic> _parseJWT(String token) {
    final tokenParts = token.split('.');
    final tokenPayload = base64Url.normalize(tokenParts[1]);
    return json.decode(utf8.decode(base64Url.decode(tokenPayload)));
  }

  void _scheduleTokenRefresh(String accessToken) {
    _refreshTimer?.cancel();

    final payload = _parseJWT(accessToken);
    final exp = payload['exp']; // Unix Timestamp in seconds

    if (exp == null) return;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();

    final difference = expiry.difference(now);

    // refresh 60s before timeout
    final refreshDuration = difference - Duration(seconds: 60);

    if (refreshDuration.isNegative) {
      refreshToken();
    } else {
      _refreshTimer = Timer(refreshDuration, () async {
        final success = await refreshToken();
        if (success) {
          final newToken = getAccessToken();
          if (newToken != null) {
            _scheduleTokenRefresh(newToken);
          }
        }
      });
    }
  }
}
