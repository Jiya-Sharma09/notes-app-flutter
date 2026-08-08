import 'package:flutter/material.dart';

class RevQuestionsScreen extends StatefulWidget {
  final int noteId;

  const RevQuestionsScreen({super.key, required this.noteId});

  @override
  State<RevQuestionsScreen> createState() => _RevQuestionsScreenState();
}

class _RevQuestionsScreenState extends State<RevQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revision Questions')),
      body: const Center(child: Placeholder()),
    );
  }
}