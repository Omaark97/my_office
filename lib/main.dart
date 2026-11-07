import 'package:flutter/material.dart';

import 'features/transactions/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Office',
      theme: ThemeData(
        // make the whole app's Scaffold background this color
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2F2F7)),
      ),
      home: const HomeScreen(title: 'Home'),
    );
  }
}
