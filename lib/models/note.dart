
import 'package:intl/intl.dart';

class Note {
  final int id;
  final String title;
  final String content;
  final int userId;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['userId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': DateFormat('yyyy-MM-dd').format(createdAt),
    };
  }

  static List<Note> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
  }
}
