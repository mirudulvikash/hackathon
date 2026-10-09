import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Display metadata for a kit item, matching the redesigned mockup lists.
class KitItemMeta {
  final String key; // stable storage key (kept compatible with old prefs)
  final String title;
  final String category;
  final String detail;
  final IconData icon;
  final bool urgent;
  final Color color;

  const KitItemMeta({
    required this.key,
    required this.title,
    required this.category,
    required this.detail,
    required this.icon,
    required this.color,
    this.urgent = false,
  });
}

class PreparednessProvider extends ChangeNotifier {
  Map<String, bool> _kitItems = {};

  /// Mockup-matching item metadata. Keys are legacy pref keys so existing
  /// SharedPreferences state keeps working.
  static const List<KitItemMeta> itemMeta = [
    KitItemMeta(
      key: 'Water & Non-perishable food',
      title: 'Water (3L) & Food Rations',
      category: 'Sustenance',
      detail: 'Non-perishable energy bars',
      icon: Icons.local_drink,
      color: Color(0xFF00695C),
    ),
    KitItemMeta(
      key: 'First-aid box',
      title: 'First-Aid Kit & Antiseptics',
      category: 'Medical',
      detail: 'Sterile gauze, bandage rolls',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF00897B),
    ),
    KitItemMeta(
      key: 'Flashlight & extra batteries',
      title: 'High-Beam Flashlight',
      category: 'Utility',
      detail: 'Extra AA batteries included',
      icon: Icons.flashlight_on_outlined,
      color: Color(0xFF00695C),
    ),
    KitItemMeta(
      key: 'Power bank',
      title: 'Power Bank (10,000mAh)',
      category: 'Electronic',
      detail: 'Full charge & USB-C cord',
      icon: Icons.battery_charging_full,
      color: Color(0xFF00897B),
    ),
    KitItemMeta(
      key: 'Whistle',
      title: 'High-Decibel Safety Whistle',
      category: 'Signaling',
      detail: 'Pealess distress whistle',
      icon: Icons.campaign_outlined,
      color: Color(0xFF00796B),
    ),
    KitItemMeta(
      key: 'Important documents in waterproof bag',
      title: 'Student ID & Documents',
      category: 'Identity',
      detail: 'Sealed in waterproof pouch',
      icon: Icons.badge_outlined,
      color: Color(0xFF00695C),
    ),
    KitItemMeta(
      key: 'Basic medicines',
      title: 'Medications & ORS Sachets',
      category: 'Urgent',
      detail: '7-day personal prescriptions',
      icon: Icons.medication_outlined,
      color: Color(0xFFE53935),
      urgent: true,
    ),
    KitItemMeta(
      key: 'Emergency cash',
      title: 'Emergency Cash Reserves',
      category: 'Finance',
      detail: 'Small notes (₹50, ₹100, ₹200)',
      icon: Icons.savings_outlined,
      color: Color(0xFF00897B),
    ),
  ];

  PreparednessProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('kit_items');
    if (jsonStr != null) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      _kitItems = map.map((key, value) => MapEntry(key, value as bool));
      // Ensure every defined meta key exists (handles newly added items).
      for (final meta in itemMeta) {
        _kitItems.putIfAbsent(meta.key, () => false);
      }
    } else {
      _kitItems = {for (final m in itemMeta) m.key: false};
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kit_items', json.encode(_kitItems));
  }

  Map<String, bool> get kitItems => _kitItems;

  bool isPacked(String key) => _kitItems[key] ?? false;

  int get completedItems => _kitItems.values.where((v) => v).length;
  int get totalItems => _kitItems.length;
  double get readinessProgress => totalItems == 0 ? 0 : completedItems / totalItems;

  /// Packed count capped to the 8 displayable mockup items.
  int get packedDisplayCount =>
      itemMeta.where((m) => _kitItems[m.key] ?? false).length;

  void toggleItem(String item, bool value) {
    if (_kitItems.containsKey(item)) {
      _kitItems[item] = value;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void toggleAll(bool value) {
    for (final m in itemMeta) {
      _kitItems[m.key] = value;
    }
    _saveToPrefs();
    notifyListeners();
  }
}
