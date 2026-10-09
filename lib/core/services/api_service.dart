import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart';
import '../../models/disaster_model.dart';
class ApiService {
  static String _customBaseUrl = '';

  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  static const Duration timeoutDuration = Duration(seconds: 5);

  // Users
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String institution,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'institution': institution,
          'location': location,
        }),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['success'] = true;
        return data;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        return {'success': false, 'error': 'EMAIL_ALREADY_EXISTS', 'message': 'An account with this email address already exists.'};
      } else if (response.statusCode == 422) {
        return {'success': false, 'error': 'VALIDATION_ERROR', 'message': 'Please check the information entered and try again.'};
      }
      return {'success': false, 'error': 'SERVER_ERROR', 'message': 'An unexpected server error occurred. Please try again later.'};
    } catch (e) {
      return {'success': false, 'error': 'NETWORK_ERROR', 'message': 'Unable to connect to the server. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> syncProfile(UserProfile profile, {int userId = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/profile?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'institution': profile.institution,
          'location': profile.location,
          'preferences': profile.preferredCategories,
        }),
      ).timeout(timeoutDuration);
      return response.statusCode == 200;
    } catch (e) {
      return false; // Backend offline
    }
  }

  static Future<bool> pingServer() async {
    try {
       final res = await http.get(Uri.parse('$baseUrl/api/disasters')).timeout(timeoutDuration);
       return res.statusCode == 200;
    } catch (e) {
       return false;
    }
  }

  static Future<List<DisasterModel>?> getRecommendations(String location, {int userId = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/$location?user_id=$userId')
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DisasterModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Quizzes
  static Future<bool> submitQuiz(String disasterId, int score, int totalQuestions, {int userId = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/quizzes/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'disaster_id': disasterId,
          'score': score,
          'total_questions': totalQuestions,
        }),
      ).timeout(timeoutDuration);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getProgress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/progress/$userId'),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> sendChatMessage(List<Map<String, String>> messages, {int? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': messages,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Achievements
  static Future<Map<String, dynamic>?> logActivity(int userId, {String? disasterId, String? activityType, String? customDate}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/achievements/log-activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'disaster_id': disasterId,
          'activity_type': activityType ?? 'lesson',
          'custom_date': customDate,
        }),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserAchievements(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/achievements/$userId'),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCertificate(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/achievements/$userId/certificate'),
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

