import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';
import 'package:notes_app_flutter/widget/note_tile.dart';
import 'package:notes_app_flutter/models/note.dart';
import 'package:notes_app_flutter/screens/read_screen.dart';

class SearchNotesScreen extends StatefulWidget {
  final String query;

  const SearchNotesScreen({super.key, required this.query});

  @override
  State<SearchNotesScreen> createState() => _SearchNotesScreenState();
}

class _SearchNotesScreenState extends State<SearchNotesScreen> {
  List<Note> _results = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSearch());
  }

  Future<void> _runSearch() async {
    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "You're not logged in.";
      });
      return;
    }

    List<Note> results = [];

    try {
      results = await notesProvider.searchTitle(widget.query, token);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final liveNotes = context.watch<NotesProvider>().notes;
    final resultIds = _results.map((n) => n.id).toSet();
    final visibleResults = liveNotes
        .where((n) => resultIds.contains(n.id))
        .toList();

    if (visibleResults.isEmpty) {
      return const Center(child: Text("No notes found"));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: visibleResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = visibleResults[index];
        return NoteTile(
          note: note,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReadScreen(noteId: note.id)),
            );
          },
        );
      },
    );
  }
}
