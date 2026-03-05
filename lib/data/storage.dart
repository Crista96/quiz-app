import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _kQuestions = 'questions_v1';
  static const _kAttempts = 'attempts_v1';

  Future<void> saveJsonList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> loadJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveQuestions(List<Map<String, dynamic>> items) => saveJsonList(_kQuestions, items);
  Future<List<Map<String, dynamic>>> loadQuestions() => loadJsonList(_kQuestions);

  Future<void> saveAttempts(List<Map<String, dynamic>> items) => saveJsonList(_kAttempts, items);
  Future<List<Map<String, dynamic>>> loadAttempts() => loadJsonList(_kAttempts);
}