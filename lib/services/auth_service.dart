import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    http.Response response;

    try {
      response = await _apiClient.post(
        '/auth/register',
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 201) {
      throw _parseAuthException(response);
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
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
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 200) {
      throw _parseAuthException(response);
    }

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Invalid response format from server.');
    }

    final user = data['user'];

    if (user is! Map<String, dynamic>) {
      throw AuthException('Malformed user data in response.');
    }

    return {
      'token': _extractToken(data),
      'userId': user['id'] as int,
      'username': user['name'] as String,
      'email': user['email'] as String,
    };
  }

  Future<Map<String, dynamic>> getUserDetails(String token) async {
    http.Response response;

    try {
      response = await _apiClient.get(
        '/auth/me',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 200) {
      throw _parseAuthException(response);
    }

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Invalid response format from server.');
    }

    final user = data['user'];

    if (user is! Map<String, dynamic>) {
      throw AuthException('Malformed user data in response.');
    }

    return {
      'id': user['id'] as int,
      'name': user['name'] as String,
      'email': user['email'] as String,
    };
  }

  String _extractToken(Map<String, dynamic> json) {
    if (json.containsKey('token') && json['token'] is String) {
      return json['token'] as String;
    }

    throw AuthException('Authentication token not found in response.');
  }

  AuthException _parseAuthException(http.Response response) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return AuthException(
        json['message']?.toString() ??
            response.reasonPhrase ??
            'Unknown auth error',
        statusCode: response.statusCode,
        code: json['code']?.toString(),
        userId: _parseUserId(json['userId']),
      );
    } catch (_) {
      return AuthException(
        response.reasonPhrase ?? 'Unknown auth error',
        statusCode: response.statusCode,
      );
    }
  }

  int? _parseUserId(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> verifyOtp(int id, String otp) async {
    http.Response response;

    try {
      response = await _apiClient.post(
        '/auth/verify-otp',
        body: jsonEncode({
          'userId': id,
          'otp': otp,
        }),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 200) {
      throw _parseAuthException(response);
    }
  }

  Future<void> resendOtp(int id) async {
    http.Response response;

    try {
      response = await _apiClient.post(
        '/auth/resend-otp',
        body: jsonEncode({
          'userId': id,
        }),
      );
    } catch (e) {
      throw AuthException('Failed to connect to the server');
    }

    if (response.statusCode != 200) {
      throw _parseAuthException(response);
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final int? userId;

  AuthException(
    this.message, {
    this.statusCode,
    this.code,
    this.userId,
  });

  @override
  String toString() =>
      'AuthException $statusCode'
      '${code != null ? ' [$code]' : ''}: $message';
}