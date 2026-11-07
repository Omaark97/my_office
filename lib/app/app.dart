import 'package:flutter/material.dart';

import '../features/transactions/presentation/screens/home_screen.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Office',
      theme: appTheme,
      home: const HomeScreen(title: 'Home'),
    );
  }
}
