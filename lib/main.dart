import 'package:flutter/material.dart';
import 'package:notes_app_flutter/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_flutter/provider/auth-provider.dart';
import 'package:notes_app_flutter/provider/notes-provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiClient(baseUrl: "")),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<ApiClient>())),
        ChangeNotifierProvider(create: (context) => NotesProvider(context.read<ApiClient>())),
      ],
    child: MyApp()));
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: ,
    );
  }
}

