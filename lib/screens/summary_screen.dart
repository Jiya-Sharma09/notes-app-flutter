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
      appBar: AppBar(title: Text('Summary'),),
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

          // Build the same tile+divider structure ListView.separated gave us,
          // but as a Column, since it now lives inside a SingleChildScrollView.
          final List<Widget> itemWidgets = [];
          for (int index = 0; index < summaryPoints.length; index++) {
            itemWidgets.add(
              ListTile(
                leading: const Icon(Icons.circle, size: 8),
                title: Text(summaryPoints[index]),
              ),
            );
            if (index != summaryPoints.length - 1) {
              itemWidgets.add(const Divider());
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: itemWidgets,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}