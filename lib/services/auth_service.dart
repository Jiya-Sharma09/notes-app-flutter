import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<String> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    http.Response response;
    try {
      response = await _apiClient.post(
        '/auth/register',
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw AuthException(
        _parseError(response),
        statusCode: response.statusCode,
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Invalid response format from server.');
    }
    return _extractToken(data);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    http.Response response;
    try {
      response = await _apiClient.post(
        '/auth/login',
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 200) {
      throw AuthException(
        _parseError(response),
        statusCode: response.statusCode,
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Invalid response format from server.');
    }
    return _extractToken(data);
  }

  String _extractToken(Map<String, dynamic> json) {
    if (json.containsKey('token') && json['token'] is String) {
      return json['token'] as String;
    }

    throw AuthException('Authentication token not found in response.');
  }

  String _parseError(http.Response response) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return json['message']?.toString() ??
          response.reasonPhrase ??
          'Unknown auth error';
    } catch (_) {
      return response.reasonPhrase ?? 'Unknown auth error';
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException $statusCode: $message';
}
