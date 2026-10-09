import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class AchievementProvider extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalActiveDays = 0;
  String? _firstLessonDate;
  String? _lastActivityDate;
  List<Map<String, dynamic>> _achievements = [];
  String? _certificateId;
  bool _certificateUnlocked = false;
  bool _isLoading = false;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalActiveDays => _totalActiveDays;
  String? get firstLessonDate => _firstLessonDate;
  String? get lastActivityDate => _lastActivityDate;
  List<Map<String, dynamic>> get achievements => _achievements;
  String? get certificateId => _certificateId;
  bool get certificateUnlocked => _certificateUnlocked;
  bool get isLoading => _isLoading;

  void reset() {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalActiveDays = 0;
    _firstLessonDate = null;
    _lastActivityDate = null;
    _achievements = [];
    _certificateId = null;
    _certificateUnlocked = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAchievements(int userId) async {
    _isLoading = true;
    notifyListeners();

    final data = await ApiService.getUserAchievements(userId);
    if (data != null) {
      _applyData(data);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> logActivity(int userId, {String? disasterId, String? activityType, String? customDate}) async {
    final data = await ApiService.logActivity(userId, disasterId: disasterId, activityType: activityType, customDate: customDate);
    List<Map<String, dynamic>> newlyUnlocked = [];
    if (data != null) {
      _applyData(data);
      if (data['newly_unlocked'] != null) {
        newlyUnlocked = List<Map<String, dynamic>>.from(data['newly_unlocked']);
      }
      notifyListeners();
    }
    return newlyUnlocked;
  }

  void _applyData(Map<String, dynamic> data) {
    _currentStreak = data['current_streak'] ?? 0;
    _longestStreak = data['longest_streak'] ?? 0;
    _totalActiveDays = data['total_active_days'] ?? 0;
    _firstLessonDate = data['first_lesson_date'];
    _lastActivityDate = data['last_activity_date'];
    _certificateId = data['certificate_id'];
    _certificateUnlocked = data['certificate_unlocked'] ?? false;

    if (data['achievements'] != null) {
      _achievements = List<Map<String, dynamic>>.from(data['achievements']);
    }
  }
}
