import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';
import 'package:notes_app_flutter/widget/note_tile.dart';
import 'package:notes_app_flutter/widget/note_banner.dart';
import 'package:notes_app_flutter/screens/add_notes.dart';
import 'package:notes_app_flutter/screens/search_notes_screen.dart';
import 'package:notes_app_flutter/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authProvider.token != null) {
        final notesProvider = context.read<NotesProvider>();
        await notesProvider.fetchAllNotes(authProvider.token!);

      } 
    });
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider authProvider) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Log out?"),
      content: const Text("You'll need to sign in again to access your notes."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            authProvider.logout();
          },
          child: const Text("Log out"),
        ),
      ],
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;
    final _authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
      title: Text(
        "Hi, ${_authProvider.userName} 👋",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Navigate to your settings screen once it exists
            // Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {},
        ),
      ],
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
