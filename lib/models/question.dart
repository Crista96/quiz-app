class Question {
  final String id;
  final String category;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int createdAtMs;

  const Question({
    required this.id,
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'prompt': prompt,
        'options': options,
        'correctIndex': correctIndex,
        'createdAtMs': createdAtMs,
      };

  static Question fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        category: (json['category'] as String?) ?? 'General',
        prompt: json['prompt'] as String,
        options: (json['options'] as List).map((e) => e.toString()).toList(),
        correctIndex: json['correctIndex'] as int,
        createdAtMs: json['createdAtMs'] as int,
      );

  Question copyWith({
    String? category,
    String? prompt,
    List<String>? options,
    int? correctIndex,
  }) =>
      Question(
        id: id,
        category: category ?? this.category,
        prompt: prompt ?? this.prompt,
        options: options ?? this.options,
        correctIndex: correctIndex ?? this.correctIndex,
        createdAtMs: createdAtMs,
      );
}