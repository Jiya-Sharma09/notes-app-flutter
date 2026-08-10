import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notes_app_flutter/services/api_client.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class RevisionQuestion {
  final String question;
  final String answer;

  RevisionQuestion({required this.question, required this.answer});
}

class AiService {
  final ApiClient apiClient;

  AiService({required this.apiClient});

  Future<List<String>> getSummary({required String token, required int noteId}) async {
    final http.Response response = await apiClient.get(
      '/ai/summary/$noteId',
      headers: {'Authorization': 'Bearer $token'},
    );

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to generate summary.',
        statusCode: response.statusCode,
      );
    }

    final dynamic summary = body['summary'];
    if (summary is! List) {
      throw ApiException('Invalid summary response from server.');
    }

    return summary.map((e) => e.toString()).toList();
  }

  Future<List<RevisionQuestion>> getRevisionQuestions({required String token, required int noteId}) async {
    final http.Response response = await apiClient.get(
      '/ai/rev/$noteId',
      headers: {'Authorization': 'Bearer $token'},
    );

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to generate revision questions.',
        statusCode: response.statusCode,
      );
    }

    final dynamic questions = body['questions'];
    final dynamic answers = body['answers'];

    if (questions is! List || answers is! List || questions.length != answers.length) {
      throw ApiException('Invalid revision questions response from server.');
    }

    return List<RevisionQuestion>.generate(
      questions.length,
      (i) => RevisionQuestion(
        question: questions[i].toString(),
        answer: answers[i].toString(),
      ),
    );
  }
}