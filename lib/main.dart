import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'state/quiz_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = QuizStore();
  await store.load(); 

  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'QuizForge',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}