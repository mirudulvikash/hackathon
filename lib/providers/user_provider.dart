import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/disaster_model.dart';
import '../core/mock_data/disaster_data.dart';
import '../core/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isBackendConnected = false;
  List<DisasterModel> _dynamicRecommendations = [];
  int? _userId;

  UserProfile? get profile => _profile;
  int? get userId => _userId;
  bool get isBackendConnected => _isBackendConnected;

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    _userId = prefs.getInt('user_id');
    if (profileJson != null) {
      _profile = UserProfile.fromJson(profileJson);
      notifyListeners();
    }
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    _isBackendConnected = await ApiService.pingServer();
    if (_profile != null && _isBackendConnected) {
      await ApiService.syncProfile(_profile!, userId: _userId ?? 1);
      if (_profile!.location.isNotEmpty) {
        final recs = await ApiService.getRecommendations(_profile!.location, userId: _userId ?? 1);
        if (recs != null) {
          _dynamicRecommendations = recs;
        }
      }
    }
    notifyListeners();
  }

  Future<void> forceBackendSync() => _syncWithBackend();

  Future<void> _saveToPrefs() async {
    if (_profile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', _profile!.toJson());
      if (_userId != null) {
        await prefs.setInt('user_id', _userId!);
      }
    }
  }

  Future<void> resetProfile() async {
    _profile = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('user_id');
    notifyListeners();
  }

  bool get isOnboardingComplete => _profile != null && _profile!.isComplete;

  List<DisasterModel> get recommendedDisasters {
    if (_profile == null || _profile!.location.isEmpty) return [];
    if (_isBackendConnected && _dynamicRecommendations.isNotEmpty) {
      return _dynamicRecommendations;
    }
    return mockDisasters.where((d) => d.relevantLocations.contains(_profile!.location)).toList();
  }

  Future<bool> login(String email, String password) async {
    final res = await ApiService.login(email, password);
    if (res != null) {
      _userId = res['user_id'];
      if (res['profile'] != null) {
          _profile = UserProfile(
            name: res['name'],
            role: res['role'],
            institution: res['profile']['institution'] ?? '',
            location: res['profile']['location'] ?? '',
            preferredCategories: [],
          );
      }
      await _saveToPrefs();
      _syncWithBackend();
      return true;
    }
    return false;
  }
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String institution,
    required String location,
  }) async {
    final res = await ApiService.register(
      name: name,
      email: email,
      password: password,
      role: role,
      institution: institution,
      location: location,
    );
    if (res['success'] == true) {
      // Intentionally omitting automatic login to enforce Registration -> Login explicit flow
    }
    return res;
  }
  void updateProfile({
    String? name,
    String? role,
    String? institution,
    String? location,
    List<String>? preferredCategories,
  }) {
    if (_profile == null) {
      _profile = UserProfile(
        name: name ?? '',
        role: role ?? '',
        institution: institution ?? '',
        location: location ?? '',
        preferredCategories: preferredCategories ?? [],
      );
    } else {
      _profile = _profile!.copyWith(
        name: name,
        role: role,
        institution: institution,
        location: location,
        preferredCategories: preferredCategories,
      );
    }
    _saveToPrefs();
    notifyListeners();
    _syncWithBackend();
  }

  void updateLocation(String newLocation) {
    if (_profile != null) {
      _profile = _profile!.copyWith(location: newLocation);
      _saveToPrefs();
      notifyListeners();
      _syncWithBackend();
    }
  }
}
