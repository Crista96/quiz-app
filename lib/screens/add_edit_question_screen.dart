import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../state/quiz_store.dart';
import '../widgets/responsive_scaffold.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final String? editId;
  const AddEditQuestionScreen({super.key, this.editId});

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final categoryCtrl = TextEditingController();
  final promptCtrl = TextEditingController();
  final optCtrls = List.generate(4, (_) => TextEditingController());

  int correctIndex = 0;
  bool initialized = false;

  @override
  void dispose() {
    categoryCtrl.dispose();
    promptCtrl.dispose();
    for (final c in optCtrls) c.dispose();
    super.dispose();
  }

  void initFrom(Question q) {
    categoryCtrl.text = q.category;
    promptCtrl.text = q.prompt;
    for (int i = 0; i < optCtrls.length; i++) {
      optCtrls[i].text = i < q.options.length ? q.options[i] : '';
    }
    correctIndex = q.correctIndex;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuizStore>();
    final isEdit = widget.editId != null;
    final q = isEdit ? store.getQuestionById(widget.editId!) : null;

    if (isEdit && q != null && !initialized) {
      initialized = true;
      initFrom(q);
    }

    return ResponsiveScaffold(
      title: isEdit ? 'Edit Question' : 'Add Question',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: promptCtrl,
              decoration: const InputDecoration(labelText: 'Question'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ...List.generate(optCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: optCtrls[i],
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              );
            }),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: correctIndex,
              decoration: const InputDecoration(labelText: 'Correct option'),
              items: List.generate(
                optCtrls.length,
                (i) => DropdownMenuItem(value: i, child: Text('Option ${i + 1}')),
              ),
              onChanged: (v) => setState(() => correctIndex = v ?? 0),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final options = optCtrls.map((c) => c.text).toList();
                final category = categoryCtrl.text;
                final prompt = promptCtrl.text;

                if (!isEdit) {
                  await store.addQuestion(
                    category: category,
                    prompt: prompt,
                    options: options,
                    correctIndex: correctIndex,
                  );
                } else if (q != null) {
                  await store.updateQuestion(
                    q.copyWith(
                      category: category.trim().isEmpty ? 'General' : category.trim(),
                      prompt: prompt.trim(),
                      options: options.map((e) => e.trim()).toList(),
                      correctIndex: correctIndex,
                    ),
                  );
                }

                if (context.mounted) context.go('/questions');
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}