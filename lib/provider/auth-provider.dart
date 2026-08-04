import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:notes_app_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String baseURL = "";
  final storage = FlutterSecureStorage();
  final ApiClient _client;
  AuthProvider(this._client);
  String? _token;
  bool isLoading = false;

  String? _name;
  String? _email;

  String? get token => _token;
  String? get userName => _name;
  String? get userEmail => _email;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    Map<String, dynamic> data;
    try {
      data = await authService.login(email: email, password: password);
      _token = data['token'] as String?;
      _name = data['user']?['name'] as String?;
      _email = data['user']?['email'] as String?;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }

    try {
      await storage.write(key: "token", value: _token);
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
      await storage.delete(key: "token");
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to logout: $e');
    }
    isLoading = false;
    _token = null;
    notifyListeners();
  }

  Future<void> autoLogin() async {
    isLoading = true;
    notifyListeners();
    try {
      final authService = AuthService(_client);
      _token = await storage.read(key: "token");
      if (_token != null) {
        final userData = await authService.getUserProfile(_token!);
        _name = userData['user']?['name'] as String?;
        _email = userData['user']?['email'] as String?;
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      _token = null;
      _name = null;
      _email = null;
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to login: $e');
    }
  }
}
