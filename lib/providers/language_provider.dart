import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isTamil = false;
  bool get isTamil => _isTamil;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isTamil = prefs.getBool('is_tamil') ?? false;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isTamil = !_isTamil;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_tamil', _isTamil);
    notifyListeners();
  }

  // Quick Translations Map
  String tr(String english, String tamil) {
    return _isTamil ? tamil : english;
  }
}
