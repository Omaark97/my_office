import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope holds the state of every provider in the app.
  runApp(const ProviderScope(child: MyApp()));
}
