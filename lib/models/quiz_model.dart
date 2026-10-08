class QuizQuestion {
  final String id;
  final String disasterId;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.disasterId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class QuizResult {
  final String disasterId;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;

  const QuizResult({
    required this.disasterId,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
  });
}
