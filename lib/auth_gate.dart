import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/screens/login_screen.dart';
import 'package:notes_app_flutter/screens/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.autoLogin();
      if (authProvider.token != null) {
        try {
          await authProvider.userDetails();
        } catch (e) {
          debugPrint('userDetails failed: $e');
          // don't rethrow — a failed name/email fetch shouldn't block navigation
        }
      }
      if (mounted) {
        setState(() => _initializing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return authProvider.token == null
        ? const LoginScreen()
        : const HomeScreen();
  }
}
