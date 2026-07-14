import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/models/note.dart';
import 'package:notes_app_flutter/services/api_client.dart';

class NoteService {
  final ApiClient _apiClient;
  String? authToken;

  NoteService({required ApiClient apiClient, required this.authToken})
    : _apiClient = apiClient;

  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $authToken',
  };

  Future<List<Note>> fetchAllNotes() async {
    http.Response response;
    try {
      response = await _apiClient.get('/notes', headers: _authHeaders);
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }
    _assertResponseOk(response);
    List<dynamic> data;
    try {
      data = jsonDecode(response.body) as List<dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format from server!');
    }
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
    http.Response response;
    try {
      response = await _apiClient.get(
        '/notes/search',
        headers: _authHeaders,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }
    _assertResponseOk(response);
    List<dynamic> data;
    try {
      data = jsonDecode(response.body) as List<dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format from server!');
    }
    return Note.listFromJson(data);
  }

  Future<Note> fetchNoteById(int id) async {
    http.Response response;
    try {
      response = await _apiClient.get('/notes/$id', headers: _authHeaders);
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }
    _assertResponseOk(response);

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format from server!');
    }
    return Note.fromJson(data);
  }

  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    http.Response response;
    try {
      response = await _apiClient.post(
        '/notes',
        headers: _authHeaders,
        body: jsonEncode({'title': title, 'content': content}),
      );
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }

    _assertResponseCreated(response);
    Map<String, dynamic> data;
    try{
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format from server!');
    }
    return Note.fromJson(data);
  }

  Future<Note> updateNote({
    required int id,
    required String title,
    required String content,
  }) async {
    http.Response response;
    try {
      response = await _apiClient.put(
        '/notes/$id',
        headers: _authHeaders,
        body: jsonEncode({'title': title, 'content': content}),
      );
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }

    _assertResponseOk(response);
    Map<String, dynamic> data;
    try {
     data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format from server!');
    }
    return Note.fromJson(data);
  }

  Future<void> deleteNote(int id) async {
    http.Response response;
    try {
      response = await _apiClient.delete(
        '/notes/$id',
        headers: _authHeaders,
      );
    } catch (e) {
      throw ApiException('Failed to connect to the server!');
    }
    _assertResponseOk(response);
  }

  void _assertResponseOk(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        _parseError(response),
        statusCode: response.statusCode,
      );
    }
  }

  void _assertResponseCreated(http.Response response) {
    if (response.statusCode != 201) {
      throw ApiException(
        _parseError(response),
        statusCode: response.statusCode,
      );
    }
  }

  String _parseError(http.Response response) {
    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ??
          response.reasonPhrase ??
          'Unknown API error';
    } catch (_) {
      return response.reasonPhrase ?? 'Unknown API error';
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException $statusCode: $message';
}
