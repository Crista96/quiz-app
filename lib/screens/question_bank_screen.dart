import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/quiz_store.dart';
import '../widgets/responsive_scaffold.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuizStore>();
    final filtered = store.questions.where((q) {
      final qLower = query.toLowerCase();
      return q.prompt.toLowerCase().contains(qLower) ||
          q.category.toLowerCase().contains(qLower);
    }).toList();

    return ResponsiveScaffold(
      title: 'Question Bank',
      actions: [
        IconButton(
          onPressed: () => context.go('/questions/new'),
          icon: const Icon(Icons.add),
          tooltip: 'Add question',
        ),
      ],
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final q = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(q.prompt),
                    subtitle: Text(q.category),
                    onTap: () => context.go('/questions/${q.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/questions/${q.id}/edit'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}