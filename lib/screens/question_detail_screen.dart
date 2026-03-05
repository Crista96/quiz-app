import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/quiz_store.dart';
import '../widgets/responsive_scaffold.dart';

class QuestionDetailScreen extends StatelessWidget {
  final String id;
  const QuestionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuizStore>();
    final q = store.getQuestionById(id);

    if (q == null) {
      return const ResponsiveScaffold(
        title: 'Question',
        child: Center(child: Text('Question not found')),
      );
    }

    final attempts = store.attemptsForQuestion(q.id);
    final pct = store.accuracyForQuestion(q.id).toStringAsFixed(1);

    return ResponsiveScaffold(
      title: 'Question Details',
      actions: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete question?'),
                content: const Text(
                  'This will permanently delete the question and its answer history.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await store.deleteQuestion(q.id);
              if (context.mounted) context.go('/questions');
            }
          },
        ),
      ],
      child: ListView(
        children: [
          Text(q.category, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(q.prompt, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          ...List.generate(q.options.length, (i) {
            final isCorrect = i == q.correctIndex;
            return Card(
              child: ListTile(
                title: Text(q.options[i]),
                trailing: isCorrect ? const Icon(Icons.check) : null,
              ),
            );
          }),

          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Statistics'),
              subtitle: Text('Attempts: $attempts • Accuracy: $pct%'),
            ),
          ),
        ],
      ),
    );
  }
}