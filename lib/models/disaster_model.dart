import 'package:flutter/material.dart';

class DisasterModel {
  final String id;
  final String name;
  final String category;
  final IconData iconName;
  final String shortDescription;
  final String whatIsIt;
  final List<String> causes;
  final List<String> warningSigns;
  final List<String> beforeActions;
  final List<String> duringActions;
  final List<String> afterActions;
  final List<String> safetyPrecautions;
  final List<String> mistakesToAvoid;
  final List<String> relevantLocations;
  final String? recommendationReason;
  final int priorityScore;

  const DisasterModel({
    required this.id,
    required this.name,
    required this.category,
    required this.iconName,
    required this.shortDescription,
    required this.whatIsIt,
    required this.causes,
    required this.warningSigns,
    required this.beforeActions,
    required this.duringActions,
    required this.afterActions,
    required this.safetyPrecautions,
    required this.mistakesToAvoid,
    required this.relevantLocations,
    this.priorityScore = 0,
    this.recommendationReason,
  });

  factory DisasterModel.fromJson(Map<String, dynamic> json) {
    
    // Parse guidelines loosely since backend structure has phase+content.
    // We map them securely to avoid parse errors when falling back to UI.
    final guidelines = json['guidelines'] as List<dynamic>? ?? [];
    List<String> getPhase(String phaseStr) {
      return guidelines
          .where((g) => g['phase'] == phaseStr)
          .map((g) => g['content'] as String)
          .toList();
    }
    
    // Map backend categories to flutter icons visually if needed, though here we just default safely
    IconData getIcon(String cat) {
      if (cat.contains('Earthquake')) return Icons.landscape;
      if (cat.contains('Flood')) return Icons.water_damage;
      if (cat.contains('Fire')) return Icons.local_fire_department;
      return Icons.warning;
    }

    return DisasterModel(
      id: json['disaster_id'] ?? '',
      name: json['disaster_name'] ?? '',
      category: json['category'] ?? '',
      iconName: getIcon(json['category'] ?? ''),
      shortDescription: json['short_description'] ?? '',
      whatIsIt: json['description'] ?? '',
      causes: List<String>.from(json['causes'] ?? []),
      warningSigns: List<String>.from(json['warning_signs'] ?? []),
      relevantLocations: List<String>.from(json['relevant_locations'] ?? []),
      beforeActions: getPhase('before'),
      duringActions: getPhase('during'),
      afterActions: getPhase('after'),
      safetyPrecautions: getPhase('precautions'),
      mistakesToAvoid: getPhase('mistakes'),
      priorityScore: json['priority_score'] ?? 0,
      recommendationReason: json['recommendation_reason'],
    );
  }
}
