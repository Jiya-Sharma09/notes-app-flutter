import 'package:flutter/material.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';
import 'package:notes_app_flutter/provider/theme_provider.dart';
import 'package:notes_app_flutter/theme.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadThemeMode(),
        ),
        Provider(create: (context) => ApiClient(baseUrl: "")),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NotesProvider(context.read<ApiClient>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      // home: ,
    );
  }
}
