import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:notes_app_flutter/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final ApiClient _client;

  AuthProvider(this._client);

  String? _token;
  bool isLoading = false;

  String? username;
  String? userEmail;
  int? userId;

  String? get token => _token;
  String? get userName => username;
  String? get userEmailAddress => userEmail;
  int? get userid => userId;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      final loginResponse = await authService.login(
        email: email,
        password: password,
      );

      _token = loginResponse['token'] as String;
      username = loginResponse['username'] as String;
      userEmail = loginResponse['email'] as String;
      userId = loginResponse['userId'] as int;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }

    try {
      await storage.write(
        key: 'token',
        value: _token,
      );
    } catch (e) {
      _token = null;
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to store token: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await storage.delete(key: 'token');

      _token = null;
      username = null;
      userEmail = null;
      userId = null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to logout: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> autoLogin() async {
    isLoading = true;
    notifyListeners();

    try {
      _token = await storage.read(key: 'token');
    } catch (e) {
      _token = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    if (_token != null) {
      try {
        final authService = AuthService(_client);

        final userData = await authService.getUserDetails(_token!);

        username = userData['name'] as String;
        userEmail = userData['email'] as String;
        userId = userData['id'] as int;
      } catch (e) {
        debugPrint(
          'autoLogin: profile fetch failed, keeping token: $e',
        );
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> userDetails() async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      final details = await authService.getUserDetails(token!);

      username = details['name'] as String;
      userEmail = details['email'] as String;
      userId = details['id'] as int;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      return await authService.signup(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(
    int id,
    String otp,
  ) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      await authService.verifyOtp(id, otp);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(int id) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      await authService.resendOtp(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}