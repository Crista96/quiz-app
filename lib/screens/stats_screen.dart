import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/quiz_store.dart';
import '../widgets/responsive_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuizStore>();
    final byCat = store.accuracyByCategory();

    return ResponsiveScaffold(
      title: 'Stats',
      child: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text('Overall'),
              subtitle: Text(
                'Attempts: ${store.totalAttempts} • '
                'Correct: ${store.totalCorrect} • '
                'Accuracy: ${store.accuracyPercent.toStringAsFixed(1)}%',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accuracy by category', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (byCat.isEmpty) const Text('No attempts yet.'),
                  ...byCat.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key)),
                            Text('${e.value.toStringAsFixed(1)}%'),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}