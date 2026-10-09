import 'package:flutter/material.dart';

/// Design tokens for the Munnarivu redesign, matching the stitched mockups.
class AppColors {
  AppColors._();

  static const Color tealDeep = Color(0xFF004D40);
  static const Color teal = Color(0xFF00695C);
  static const Color tealMid = Color(0xFF26A69A);
  static const Color mintChip = Color(0xFFB9E8DF); // origin/ta? pill + chips
  static const Color cardBg = Color(0xFFEAF6F3); // module card background
  static const Color imagePlaceholder = Color(0xFFD8EFEB);
  static const Color pageBg = Color(0xFFF4FAF8);
  static const Color sosRed = Color(0xFFC62828);
  static const Color sosRedDark = Color(0xFFB71C1C);
  static const Color badgeNaturalBg = Color(0xFFDFF2EC);
  static const Color badgeNaturalFg = Color(0xFF00695C);
  static const Color badgeManMadeBg = Color(0xFFFFE3D9);
  static const Color badgeManMadeFg = Color(0xFFD84315);
  static const Color badgeCriticalBg = Color(0xFFD62828);
  static const Color textDark = Color(0xFF10312B);
  static const Color textMuted = Color(0xFF6B8A83);
}

/// Description lines shown under each module title on the Learn tab,
/// mirroring the mockup copy.
const Map<String, String> moduleLongDescriptions = {
  'd1': 'Learn how to detect flash floods, navigate waterlogged roads, and reach high ground safely during campus emergencies.',
  'd2': 'Drop, Cover, Hold On instructions for classroom, lab, and hostel safety with aftershock mitigation.',
  'd3': 'Early warning signals, windward window protection, securing loose roofing, and blackout readiness.',
  'd4': 'Recognizing saturated soil shifts, hillside fractures, retaining wall stress, and rapid evacuation triggers.',
  'd5': 'PASS technique for extinguishers, low-smoke crawling procedures, breaker trip points, and no-lift evacuation rules.',
  'd6': 'Corrosive spill protocol, ventilation fume hood operation, chemical neutralizers, and 15-minute exposure response.',
};

String longDescriptionFor(String id) =>
    moduleLongDescriptions[id] ?? '';
