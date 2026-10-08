import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreparednessProvider extends ChangeNotifier {
  Map<String, bool> _kitItems = {};

  PreparednessProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('kit_items');
    if (jsonStr != null) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      _kitItems = map.map((key, value) => MapEntry(key, value as bool));
    } else {
      _kitItems = {
        'Water & Non-perishable food': false,
        'First-aid box': false,
        'Flashlight & extra batteries': false,
        'Power bank': false,
        'Whistle': false,
        'Important documents in waterproof bag': false,
        'Basic medicines': false,
        'Emergency cash': false,
      };
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kit_items', json.encode(_kitItems));
  }

  Map<String, bool> get kitItems => _kitItems;

  int get completedItems => _kitItems.values.where((v) => v).length;
  int get totalItems => _kitItems.length;
  double get readinessProgress => totalItems == 0 ? 0 : completedItems / totalItems;

  void toggleItem(String item, bool value) {
    if (_kitItems.containsKey(item)) {
      _kitItems[item] = value;
      _saveToPrefs();
      notifyListeners();
    }
  }
}
