import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'providers/preparedness_provider.dart';
import 'providers/learning_progress_provider.dart';
import 'features/onboarding_auth/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PreparednessProvider()),
        ChangeNotifierProvider(create: (_) => LearningProgressProvider()),
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
      title: 'Munnarivu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
