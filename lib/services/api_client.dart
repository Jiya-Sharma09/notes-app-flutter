import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({required this.baseUrl, http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<http.Response> get(String path, {Map<String, String>? headers, Map<String, String>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    return _httpClient.get(uri, headers: _defaultHeaders(headers));
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return _httpClient.post(uri, headers: _defaultHeaders(headers), body: body);
  }

  Future<http.Response> put(String path, {Map<String, String>? headers, Object? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return _httpClient.put(uri, headers: _defaultHeaders(headers), body: body);
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _httpClient.delete(uri, headers: _defaultHeaders(headers));
  }

  Map<String, String> _defaultHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
  }

  void close() {
    _httpClient.close();
  }
}
