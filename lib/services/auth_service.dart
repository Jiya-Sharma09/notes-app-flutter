import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<void> signup({
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

    if (response.statusCode != 201) {
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
    
  }

  Future<Map<String, dynamic>> login({
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
    
    if (!data.containsKey('token') || data['token'] is! String) {
      throw AuthException('Authentication token not found in response.');
    }
    
    return data;
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    http.Response response;
    try {
      response = await _apiClient.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $token'},
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
    return data;
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
