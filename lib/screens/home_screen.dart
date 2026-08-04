import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
          },
        ),
      ),
      body: Center(
        child: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
          },
        ),
      ),
    );
  }
}
