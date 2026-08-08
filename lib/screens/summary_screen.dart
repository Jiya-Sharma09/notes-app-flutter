import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget {
  final int noteId;

  const SummaryScreen({super.key, required this.noteId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: const Center(child: Placeholder()),
    );
  }
}