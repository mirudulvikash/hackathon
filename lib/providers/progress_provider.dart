import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class ProgressProvider extends ChangeNotifier {
  final Map<String, QuizResult> _quizResults = {};
  
  Map<String, QuizResult> get quizResults => _quizResults;
  
  void saveResult(QuizResult result) {
    if (_quizResults.containsKey(result.disasterId)) {
      if (result.score > _quizResults[result.disasterId]!.score) {
        _quizResults[result.disasterId] = result;
      }
    } else {
      _quizResults[result.disasterId] = result;
    }
    notifyListeners();
  }

  int get completedTopicsCount => _quizResults.length;
  
  double get averageScorePercent {
    if (_quizResults.isEmpty) return 0.0;
    double totalPercent = 0.0;
    for (var result in _quizResults.values) {
      totalPercent += (result.score / result.totalQuestions);
    }
    return (totalPercent / _quizResults.length) * 100;
  }
}
