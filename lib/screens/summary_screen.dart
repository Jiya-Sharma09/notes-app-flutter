import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/services/ai_service.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';

class SummaryScreen extends StatefulWidget {
  final int noteId;

  const SummaryScreen({super.key, required this.noteId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Future<List<String>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummary();
  }

  Future<List<String>> _fetchSummary() {
    final token = context.read<AuthProvider>().token;
    final aiService = context.read<AiService>();
    return aiService.getSummary(token: token!, noteId: widget.noteId);
  }

  void _retry() {
    setState(() {
      _summaryFuture = _fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: FutureBuilder<List<String>>(
        future: _summaryFuture,
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

          final summaryPoints = snapshot.data ?? [];

          if (summaryPoints.isEmpty) {
            return const Center(child: Text('No summary available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: summaryPoints.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.circle, size: 8),
                title: Text(summaryPoints[index]),
              );
            },
          );
        },
      ),
    );
  }
}