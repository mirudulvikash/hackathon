import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import '../dashboard/main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingState();
  }

  Future<void> _checkOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasProfile = prefs.getString('user_profile') != null;
    
    // Simulate 2 second loading time for branding effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (hasProfile) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield,
              size: 100,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'MUNNARIVU',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Disaster Awareness, Preparedness\n& Response',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
