import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  int streakDays = 5; // Impressive demo data
  
  LearningProgressProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('learning_progress');
    if (jsonStr != null) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      map.forEach((key, value) {
        _progress[key] = TopicProgress.fromJson(value);
      });
    } else {
      _initDemoData();
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _progress.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('learning_progress', json.encode(map));
  }

  
  void _initDemoData() {
    // Pre-populate realistic, impressive demo progress data
    _progress['d1'] = TopicProgress(disasterId: 'd1', isRead: true, highestQuizScore: 4, totalQuizQuestions: 4); // Flood: 100%
    _progress['d5'] = TopicProgress(disasterId: 'd5', isRead: true, highestQuizScore: 4, totalQuizQuestions: 4); // Fire: 100%
    _progress['d2'] = TopicProgress(disasterId: 'd2', isRead: true, highestQuizScore: 3, totalQuizQuestions: 4); // Earthquake 75% -> 100% mastery
    _progress['d3'] = TopicProgress(disasterId: 'd3', isRead: true); // Cyclone: 50% (Only read)
    _progress['d6'] = TopicProgress(disasterId: 'd6', isRead: true, highestQuizScore: 1, totalQuizQuestions: 4); // Lab Accident: 75% progress but < 60% score (Weak Area)
  }

  void markTopicAsRead(String disasterId) {
    if (!_progress.containsKey(disasterId)) {
      _progress[disasterId] = TopicProgress(disasterId: disasterId);
    }
    _progress[disasterId]!.isRead = true;
    _saveToPrefs();
    notifyListeners();
  }
  
  void saveQuizResult(QuizResult result) {
    if (!_progress.containsKey(result.disasterId)) {
      _progress[result.disasterId] = TopicProgress(disasterId: result.disasterId);
    }
    
    final currentProgress = _progress[result.disasterId]!;
    // Automatically flag as read since they obviously interacted enough to take the quiz
    currentProgress.isRead = true; 
    
    if (currentProgress.highestQuizScore == null || result.score > currentProgress.highestQuizScore!) {
      currentProgress.highestQuizScore = result.score;
      currentProgress.totalQuizQuestions = result.totalQuestions;
    }
    _saveToPrefs();
    notifyListeners();
    // Silently sync to backend
    ApiService.submitQuiz(result.disasterId, result.score, result.totalQuestions);
  }
  
  double get overallCompletionPercentage {
    if (mockDisasters.isEmpty) return 0.0;
    double total = 0;
    for (var d in mockDisasters) {
      total += _progress[d.id]?.percentage ?? 0.0;
    }
    return total / mockDisasters.length;
  }
  
  int get completedCategoriesCount {
    return _progress.values.where((p) => p.percentage == 100.0).length;
  }

  int get totalAssessmentsTaken {
    return _progress.values.where((p) => p.highestQuizScore != null).length;
  }
  
  double get averageQuizScore {
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
    // 1. Incomplete topics relevant to user location
    final relevantIncomplete = mockDisasters.where((d) {
      return d.relevantLocations.contains(userLocation) && (_progress[d.id]?.percentage ?? 0) < 100;
    }).toList();
    if (relevantIncomplete.isNotEmpty) return relevantIncomplete.first;
    
    // 2. Any incomplete topic
    final generallyIncomplete = mockDisasters.where((d) {
      return (_progress[d.id]?.percentage ?? 0) < 100;
    }).toList();
    return generallyIncomplete.isNotEmpty ? generallyIncomplete.first : null;
  }
  
  TopicProgress? getProgressForTopic(String disasterId) => _progress[disasterId];
}
