import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'providers/preparedness_provider.dart';
import 'providers/learning_progress_provider.dart';
import 'providers/language_provider.dart';
import 'providers/achievement_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/onboarding_auth/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PreparednessProvider()),
        ChangeNotifierProvider(create: (_) => LearningProgressProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: const MunnarivuApp(),
    ),
  );
}

class MunnarivuApp extends StatelessWidget {
  const MunnarivuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Munnarivu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          primary: const Color(0xFF00695C),
          surface: const Color(0xFFF4FAF8),
          error: const Color(0xFFD62828),
          tertiary: const Color(0xFFF59E0B),
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
