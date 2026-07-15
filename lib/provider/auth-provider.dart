import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:notes_app_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String baseURL = "";
  final storage = FlutterSecureStorage();
  late final ApiClient _client = ApiClient(baseUrl: baseURL);
  late final AuthService _authService = AuthService(_client);
  String? _token;

  AuthProvider();

  String? get token => _token;

  Future<void> login({required String email, required String password}) async {
    _token = await _authService.login(email: email, password: password);

    try {
      await storage.write(key: "token", value: _token);
    } catch (e) {
      _token = null;
      throw Exception('Failed to store token: $e');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: "token");
    } catch (e) {
      throw Exception('Failed to logout!');
    }
    _token = null;
    notifyListeners();
  }
}
