import 'package:flutter/material.dart';
import 'dart:async';
import 'package:notes_app_flutter/auth_gate.dart';
import 'package:notes_app_flutter/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/images/logo_smart.png'),
          radius: 80,
        ),
      ),
    );
  }
}
