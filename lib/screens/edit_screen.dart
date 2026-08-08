import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  final int noteId;

  const EditScreen({super.key, required this.noteId});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: const Center(child: Placeholder()),
    );
  }
}