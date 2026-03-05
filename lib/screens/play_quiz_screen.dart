import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../state/quiz_store.dart';
import '../widgets/responsive_scaffold.dart';

class PlayQuizScreen extends StatefulWidget {
  const PlayQuizScreen({super.key});

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  String category = 'All';
  int count = 5;

  List<Question>? quiz;
  int index = 0;
  int correct = 0;
  bool finished = false;

  void start(QuizStore store) {
    final picked = store.buildQuiz(category: category == 'All' ? null : category, count: count);
    setState(() {
      quiz = picked;
      index = 0;
      correct = 0;
      finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuizStore>();
    final categories = <String>{'All', ...store.questions.map((q) => q.category)}.toList()..sort();

    final qList = quiz;
    final isRunning = qList != null && qList.isNotEmpty && !finished;

    return ResponsiveScaffold(
      title: 'Play Quiz',
      child: isRunning ? _QuizRunner(
        question: qList[index],
        progressText: '${index + 1} / ${qList.length}',
        onAnswer: (selected) async {
          final q = qList[index];
          final isCorrect = selected == q.correctIndex;
          await store.answerQuestion(question: q, selectedIndex: selected);

          setState(() {
            if (isCorrect) correct++;
            if (index + 1 >= qList.length) {
              finished = true;
            } else {
              index++;
            }
          });
        },
      ) : _SetupOrSummary(
        categories: categories,
        category: category,
        count: count,
        totalQuestions: store.questions.length,
        summary: finished && qList != null ? 'Score: $correct / ${qList.length}' : null,
        onCategoryChanged: (v) => setState(() => category = v),
        onCountChanged: (v) => setState(() => count = v),
        onStart: () => start(store),
      ),
    );
  }
}

class _SetupOrSummary extends StatelessWidget {
  final List<String> categories;
  final String category;
  final int count;
  final int totalQuestions;
  final String? summary;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;

  const _SetupOrSummary({
    required this.categories,
    required this.category,
    required this.count,
    required this.totalQuestions,
    required this.summary,
    required this.onCategoryChanged,
    required this.onCountChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final countOptions = [3, 5, 10];

    return ListView(
      children: [
        if (summary != null) ...[
          Card(child: ListTile(title: const Text('Finished'), subtitle: Text(summary!))),
          const SizedBox(height: 12),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Category')),
                    DropdownButton<String>(
                      value: category,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => onCategoryChanged(v ?? 'All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Text('Number of questions')),
                    DropdownButton<int>(
                      value: countOptions.contains(count) ? count : 5,
                      items: countOptions.map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
                      onChanged: (v) => onCountChanged(v ?? 5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: totalQuestions == 0 ? null : onStart,
                  child: const Text('Start quiz'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizRunner extends StatelessWidget {
  final Question question;
  final String progressText;
  final ValueChanged<int> onAnswer;

  const _QuizRunner({
    required this.question,
    required this.progressText,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    final options = question.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(progressText, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        // Responsive: grid on tablet, list on mobile
        Expanded(
          child: isTablet
              ? GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: List.generate(options.length, (i) {
                    return Card(
                      child: InkWell(
                        onTap: () => onAnswer(i),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(options[i], textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    );
                  }),
                )
              : ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => Card(
                    child: ListTile(
                      title: Text(options[i]),
                      onTap: () => onAnswer(i),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}