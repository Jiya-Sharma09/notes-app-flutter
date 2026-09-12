import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/models/note.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';

class EditScreen extends StatefulWidget {
  final Note note;

  const EditScreen({super.key, required this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final changed = _titleController.text != widget.note.title ||
        _contentController.text != widget.note.content;
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving || !_hasChanges) return;

    final authToken = context.read<AuthProvider>().token;
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired — please log in again')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final notesProvider = context.read<NotesProvider>();
    final success = await notesProvider.updateNote(
      widget.note.id,
      _titleController.text,
      _contentController.text,
      authToken,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      setState(() => _hasChanges = false);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.inverseSurface,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              Text('Saved', style: TextStyle(color: colorScheme.onInverseSurface)),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.inverseSurface,
          content: Text(
            notesProvider.errorMessageUpdate.isNotEmpty
                ? notesProvider.errorMessageUpdate
                : 'Failed to save note',
            style: TextStyle(color: colorScheme.onInverseSurface),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit note',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(width: 10),
            AnimatedOpacity(
              opacity: _hasChanges ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Unsaved',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: (_hasChanges && !_isSaving) ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isSaving
                      ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    _isSaving ? 'Saving' : 'Save',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Untitled',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    fontWeight: FontWeight.w800,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.7,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing…',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardAppearance: Brightness.light,
                  cursorColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}