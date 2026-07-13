import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/models/note.dart';
import 'package:notes_app_flutter/services/api_client.dart';

class NoteService {
  final ApiClient _apiClient;
  final String authToken;

  NoteService({required ApiClient apiClient, required this.authToken}) : _apiClient = apiClient;

  Map<String, String> get _authHeaders => {'Authorization': 'Bearer $authToken'};

  Future<List<Note>> fetchAllNotes() async {
    final response = await _apiClient.get(
      '/notes',
      headers: _authHeaders,
    );
    _assertResponseOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return Note.listFromJson(data);
  }

  Future<List<Note>> searchNotes({String? title, DateTime? createdAt}) async {
    final queryParameters = <String, String>{};
    if (title != null && title.isNotEmpty) {
      queryParameters['title'] = title;
    }
    if (createdAt != null) {
      queryParameters['createdAt'] = DateFormat('yyyy-MM-dd').format(createdAt);
    }

    final response = await _apiClient.get(
      '/notes/search',
      headers: _authHeaders,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    _assertResponseOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return Note.listFromJson(data);
  }

  Future<Note> fetchNoteById(int id) async {
    final response = await _apiClient.get(
      '/notes/$id',
      headers: _authHeaders,
    );
    _assertResponseOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Note.fromJson(data);
  }

  Future<Note> createNote({required String title, required String content}) async {
    final response = await _apiClient.post(
      '/notes',
      headers: _authHeaders,
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );
    _assertResponseCreated(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Note.fromJson(data);
  }

  Future<Note> updateNote({required int id, required String title, required String content}) async {
    final response = await _apiClient.put(
      '/notes/$id',
      headers: _authHeaders,
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );
    _assertResponseOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Note.fromJson(data);
  }

  Future<void> deleteNote(int id) async {
    final response = await _apiClient.delete(
      '/notes/$id',
      headers: _authHeaders,
    );
    _assertResponseOk(response);
  }

  void _assertResponseOk(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(_parseError(response));
    }
  }

  void _assertResponseCreated(http.Response response) {
    if (response.statusCode != 201) {
      throw ApiException(_parseError(response));
    }
  }

  String _parseError(http.Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? response.reasonPhrase ?? 'Unknown API error';
    } catch (_) {
      return response.reasonPhrase ?? 'Unknown API error';
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
