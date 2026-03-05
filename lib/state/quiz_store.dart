import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/storage.dart';
import '../models/question.dart';
import '../models/attempt.dart';

class QuizStore extends ChangeNotifier {
  final Storage _storage = Storage();

  final List<Question> _questions = [];
  final List<Attempt> _attempts = [];

  List<Question> get questions => List.unmodifiable(_questions);
  List<Attempt> get attempts => List.unmodifiable(_attempts);

  Future<void> load() async {
    final q = await _storage.loadQuestions();
    final a = await _storage.loadAttempts();

    _questions
      ..clear()
      ..addAll(q.map(Question.fromJson));

    _attempts
      ..clear()
      ..addAll(a.map(Attempt.fromJson));

    if (_questions.isEmpty) {
      _seedDefaults();
      await _persistAll();
    }

    notifyListeners();
  }

  Future<void> _persistAll() async {
    await _storage.saveQuestions(_questions.map((e) => e.toJson()).toList());
    await _storage.saveAttempts(_attempts.map((e) => e.toJson()).toList());
  }

  void _seedDefaults() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _questions.addAll([
      Question(
        id: 'q1',
        category: 'General',
        prompt: 'What is the capital of Finland?',
        options: const ['Helsinki', 'Turku', 'Tampere', 'Oulu'],
        correctIndex: 0,
        createdAtMs: now,
      ),
      Question(
        id: 'q2',
        category: 'Programming',
        prompt: 'Which keyword creates an immutable variable in Dart?',
        options: const ['var', 'final', 'mut', 'let'],
        correctIndex: 1,
        createdAtMs: now,
      ),
    ]);
  }

  Future<void> addQuestion({
    required String category,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) async {
    final id = 'q_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
    _questions.add(
      Question(
        id: id,
        category: category.trim().isEmpty ? 'General' : category.trim(),
        prompt: prompt.trim(),
        options: options.map((e) => e.trim()).toList(),
        correctIndex: correctIndex,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _persistAll();
    notifyListeners();
  }

  Future<void> updateQuestion(Question updated) async {
    final i = _questions.indexWhere((q) => q.id == updated.id);
    if (i == -1) return;
    _questions[i] = updated;
    await _persistAll();
    notifyListeners();
  }

  Question? getQuestionById(String id) {
    final i = _questions.indexWhere((q) => q.id == id);
    if (i == -1) return null;
    return _questions[i];
  }

  List<Question> buildQuiz({String? category, int count = 5}) {
    final pool = category == null || category == 'All'
        ? List<Question>.from(_questions)
        : _questions.where((q) => q.category == category).toList();

    pool.shuffle();
    if (pool.length <= count) return pool;
    return pool.take(count).toList();
  }

  
  Future<void> deleteQuestion(String id) async {
  _questions.removeWhere((q) => q.id == id);

  _attempts.removeWhere((a) => a.questionId == id);

  await _persistAll();
  notifyListeners();
}

  Future<void> answerQuestion({
    required Question question,
    required int selectedIndex,
  }) async {
    final isCorrect = selectedIndex == question.correctIndex;
    _attempts.add(
      Attempt(
        questionId: question.id,
        selectedIndex: selectedIndex,
        isCorrect: isCorrect,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _persistAll();
    notifyListeners();
  }

  int get totalAttempts => _attempts.length;
  int get totalCorrect => _attempts.where((a) => a.isCorrect).length;

  double get accuracyPercent {
    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts) * 100.0;
  }

  int attemptsForQuestion(String questionId) =>
      _attempts.where((a) => a.questionId == questionId).length;

  double accuracyForQuestion(String questionId) {
    final relevant = _attempts.where((a) => a.questionId == questionId).toList();
    if (relevant.isEmpty) return 0;
    final correct = relevant.where((a) => a.isCorrect).length;
    return (correct / relevant.length) * 100.0;
  }

  Map<String, double> accuracyByCategory() {
    final Map<String, List<Attempt>> byCat = {};
    for (final a in _attempts) {
      final q = getQuestionById(a.questionId);
      if (q == null) continue;
      byCat.putIfAbsent(q.category, () => []).add(a);
    }
    return byCat.map((cat, list) {
      final correct = list.where((x) => x.isCorrect).length;
      final pct = list.isEmpty ? 0.0 : (correct / list.length) * 100.0;
      return MapEntry(cat, pct);
    });
  }
}

