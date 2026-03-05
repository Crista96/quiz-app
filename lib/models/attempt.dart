class Attempt {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final int timestampMs;

  const Attempt({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'isCorrect': isCorrect,
        'timestampMs': timestampMs,
      };

  static Attempt fromJson(Map<String, dynamic> json) => Attempt(
        questionId: json['questionId'] as String,
        selectedIndex: json['selectedIndex'] as int,
        isCorrect: json['isCorrect'] as bool,
        timestampMs: json['timestampMs'] as int,
      );
}