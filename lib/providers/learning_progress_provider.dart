import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/disaster_model.dart';
import '../core/mock_data/disaster_data.dart';
import '../core/services/api_service.dart';

class TopicProgress {
  final String disasterId;
  bool isRead; // 50%
  int? highestQuizScore;
  int? totalQuizQuestions;
  
  TopicProgress({
    required this.disasterId,
    this.isRead = false,
    this.highestQuizScore,
    this.totalQuizQuestions,
  });
  
  double get percentage {
    if (highestQuizScore != null && totalQuizQuestions != null && totalQuizQuestions! > 0) {
      double quizPercent = (highestQuizScore! / totalQuizQuestions!) * 100;
      if (quizPercent >= 60) return 100.0;
      if (isRead) return 75.0; // Read but failed quiz (< 60)
    }
    if (isRead) return 50.0;
    return 0.0;
  }
  Map<String, dynamic> toJson() => {
    'disasterId': disasterId,
    'isRead': isRead,
    'highestQuizScore': highestQuizScore,
    'totalQuizQuestions': totalQuizQuestions,
  };

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      disasterId: json['disasterId'],
      isRead: json['isRead'] ?? false,
      highestQuizScore: json['highestQuizScore'],
      totalQuizQuestions: json['totalQuizQuestions'],
    );
  }
}

class LearningProgressProvider extends ChangeNotifier {
  final Map<String, TopicProgress> _progress = {};
  int streakDays = 0; // Removed dummy data
  
  LearningProgressProvider() {
    // Only load from prefs if we want offline support, but we should clear on logout.
  }

  void reset() {
    _progress.clear();
    _backendStats = null;
    streakDays = 0;
    notifyListeners();
  }

  Map<String, dynamic>? _backendStats;

  Future<void> syncProgress(int userId) async {
    final stats = await ApiService.getProgress(userId);
    if (stats != null) {
      _progress.clear(); // Ensure we don't bleed previous user state
      _backendStats = stats;
      // Merge progress into topic map
      for (var t in stats['topics']) {
        final dId = t['disaster_id'];
        if (!_progress.containsKey(dId)) {
          _progress[dId] = TopicProgress(disasterId: dId);
        }
        _progress[dId]!.isRead = true;
        if (t['completion_percentage'] == 100.0) {
           _progress[dId]!.highestQuizScore = 1; // Mark as passed
           _progress[dId]!.totalQuizQuestions = 1;
        }
      }
      notifyListeners();
    }
  }

  void markTopicAsRead(String disasterId) {
    if (!_progress.containsKey(disasterId)) {
      _progress[disasterId] = TopicProgress(disasterId: disasterId);
    }
    _progress[disasterId]!.isRead = true;
    notifyListeners();
  }
  
  Future<bool> saveQuizResult(QuizResult result, {int userId = 1}) async {
    if (!_progress.containsKey(result.disasterId)) {
      _progress[result.disasterId] = TopicProgress(disasterId: result.disasterId);
    }
    
    final currentProgress = _progress[result.disasterId]!;
    currentProgress.isRead = true; 
    
    if (currentProgress.highestQuizScore == null || result.score > currentProgress.highestQuizScore!) {
      currentProgress.highestQuizScore = result.score;
      currentProgress.totalQuizQuestions = result.totalQuestions;
    }
    
    bool ok = await ApiService.submitQuiz(result.disasterId, result.score, result.totalQuestions, userId: userId);
    if (ok) {
       await syncProgress(userId); // Re-sync dashboard!
    }
    return ok;
  }
  
  double get overallCompletionPercentage {
    if (_backendStats != null && _backendStats!['overall_completion_percentage'] != null) {
      return _backendStats!['overall_completion_percentage'] / 100.0; // Assume backend returns 0-100, we need 0.0-1.0
    }
    return 0.0;
  }
  
  int get completedCategoriesCount {
    if (_backendStats != null && _backendStats!['topics_assessed_count'] != null) {
      return _backendStats!['topics_assessed_count'];
    }
    return _progress.values.where((p) => p.highestQuizScore != null).length;
  }

  int get totalAssessmentsTaken {
    return _progress.values.where((p) => p.highestQuizScore != null).length;
  }
  
  double get averageQuizScore {
    if (_backendStats != null && _backendStats!['average_quiz_score'] != null) {
      return (_backendStats!['average_quiz_score'] as num).toDouble();
    }
    final quizzesTaken = _progress.values.where((p) => p.highestQuizScore != null).toList();
    if (quizzesTaken.isEmpty) return 0.0;
    double totalPercent = 0.0;
    for (var p in quizzesTaken) {
      totalPercent += (p.highestQuizScore! / p.totalQuizQuestions!) * 100;
    }
    return (totalPercent / quizzesTaken.length);
  }
  
  List<DisasterModel> get weakAreas {
    return mockDisasters.where((d) {
      final p = _progress[d.id];
      if (p != null && p.highestQuizScore != null) {
        double scorePercent = (p.highestQuizScore! / p.totalQuizQuestions!) * 100;
        return scorePercent < 60;
      }
      return false;
    }).toList();
  }
  
  DisasterModel? getRecommendedNextTopic(String userLocation) {
    // Only suggest topics the user has ACTUALLY started but not completed
    final inProgress = mockDisasters.where((d) {
      final p = _progress[d.id]?.percentage ?? 0;
      return p > 0 && p < 100;
    }).toList();
    
    if (inProgress.isNotEmpty) {
      // Prioritize location-relevant ones they started
      final relevant = inProgress.where((d) => d.relevantLocations.contains(userLocation)).toList();
      return relevant.isNotEmpty ? relevant.first : inProgress.first;
    }
    
    // No learning activity yet
    return null;
  }
  
  TopicProgress? getProgressForTopic(String disasterId) => _progress[disasterId];
}
