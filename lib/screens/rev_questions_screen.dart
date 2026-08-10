import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/services/ai_service.dart';

class RevQuestionsScreen extends StatefulWidget {
  final int noteId;

  const RevQuestionsScreen({super.key, required this.noteId});

  @override
  State<RevQuestionsScreen> createState() => _RevQuestionsScreenState();
}

class _RevQuestionsScreenState extends State<RevQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<RevisionQuestion>> _questionsFuture;
  late AnimationController _flipController;

  int _currentIndex = 0;
  bool _showingAnswer = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<List<RevisionQuestion>> _fetchQuestions() {
    final token = context.read<AuthProvider>().token;
    final aiService = context.read<AiService>();
    return aiService.getRevisionQuestions(token: token!, noteId: widget.noteId);
  }

  void _retry() {
    setState(() {
      _questionsFuture = _fetchQuestions();
      _currentIndex = 0;
      _showingAnswer = false;
      _flipController.reset();
    });
  }

  void _flipCard() {
    if (_showingAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showingAnswer = !_showingAnswer;
    });
  }

  void _goToNext(int total) {
    if (_currentIndex >= total - 1) return;
    setState(() {
      _currentIndex++;
      _showingAnswer = false;
    });
    _flipController.reset();
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _showingAnswer = false;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revision Questions')),
      body: FutureBuilder<List<RevisionQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Something went wrong. Please try again.';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text('No revision questions available.'));
          }

          final current = questions[_currentIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Card ${_currentIndex + 1} of ${questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        final angle = _flipController.value * pi;
                        final isBack = _flipController.value >= 0.5;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(angle),
                          child: isBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _FlashCardFace(
                                    label: 'ANSWER',
                                    text: current.answer,
                                  ),
                                )
                              : _FlashCardFace(
                                  label: 'QUESTION',
                                  text: current.question,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Tap the card to flip',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentIndex < questions.length - 1
                          ? () => _goToNext(questions.length)
                          : null,
                      label: const Text('Next'),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlashCardFace extends StatelessWidget {
  final String label;
  final String text;

  const _FlashCardFace({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}