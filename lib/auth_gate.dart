import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/screens/login_screen.dart';
import 'package:notes_app_flutter/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    authProvider.autoLogin();
    final token = authProvider.token;
    if (token == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
