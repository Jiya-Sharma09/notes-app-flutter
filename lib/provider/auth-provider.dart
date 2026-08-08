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
  String? username;
  String? userEmail;
  String? userId;

  String? _name;
  String? _email;

  String? get token => _token;
  String? get userName => username;
  String? get userEmailAddress => userEmail;
  String? get userid => userId;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      _token = await authService.login(email: email, password: password);
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

  Future<void> userDetails() async {
    isLoading = true;
    notifyListeners();

    final authService = AuthService(_client);

    try {
      final userDetails = await authService.getUserDetails(token!);
      username = userDetails['name'];
      userEmail = userDetails['email'];
      userId = userDetails['id'].toString();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }
}
