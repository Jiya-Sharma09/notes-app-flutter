import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';
import 'package:provider/provider.dart';

class AddNotesScreen extends StatefulWidget {
  const AddNotesScreen({super.key});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before creating a note.')),
      );
      return;
    }

    await notesProvider.createNote(
      _titleController.text.trim(),
      _contentController.text.trim(),
      token,
    );

    if (!mounted) return;

    if (notesProvider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notesProvider.errorMessage)),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(_today, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      hintText: 'Write your note here...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (notesProvider.isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: notesProvider.isLoading ? null : _createNote,
        icon: const Icon(Icons.check),
        label: const Text('Create Note'),
      ),
    );
  }
}
