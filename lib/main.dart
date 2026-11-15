import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/documents/data/temporary_document_files.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  unawaited(TemporaryDocumentFiles().clearAll().catchError((Object _) {}));
  runApp(const ProviderScope(child: MyApp()));
}
