import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';
import 'package:notes_app_flutter/widget/note_tile.dart';
import 'package:notes_app_flutter/services/auth_service.dart';
import 'package:notes_app_flutter/widget/note_banner.dart';
import 'package:notes_app_flutter/provider/theme_provider.dart';
import 'package:notes_app_flutter/screens/add_notes.dart';
import 'package:notes_app_flutter/screens/search_notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  @override
  void initState() {
    super.initState();
    debugPrint('HOME SCREEN INIT STATE CALLED');
    final authProvider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authProvider.token != null) {
        final notesProvider = context.read<NotesProvider>();
        await notesProvider.fetchAllNotes(authProvider.token!);

        // TEMP DEBUG — remove once diagnosed
        debugPrint('TOKEN: ${authProvider.token}');
        debugPrint('ERROR MESSAGE: "${notesProvider.errorMessage}"');
        debugPrint('NOTES COUNT: ${notesProvider.notes.length}');
      } else {
        debugPrint('TOKEN IS NULL — fetch never called');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme = context.watch<ThemeProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;
    final _authService = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _authService.logout();
          },
          icon: Icon(Icons.logout),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSearchBar(
                label: "Search notes",
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                searchDecoration: InputDecoration(
                  hintText: "Search notes",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                onFieldSubmitted: (value) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SearchNotesScreen(query: value),
                  ));
                },
              ),
              NewNoteBanner(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => AddNotesScreen()));
                },
              ),

              const SizedBox(height: 28),

              Text(
                "ALL NOTES",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.fontFamily,
                ),
              ),

              const SizedBox(height: 16),
              notesProvider.errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        "Error: ${notesProvider.errorMessage}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : notes.isEmpty
                  ? const Center(child: Text("No notes yet"))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return NoteTile(note: note, onTap: () {});
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
