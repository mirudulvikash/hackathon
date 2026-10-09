import 'package:flutter/material.dart';
import '../disaster_learning/disaster_list_screen.dart';
import '../preparedness/preparedness_screen.dart';
import '../emergency_response/emergency_guide_screen.dart';
import '../progress_tracker/progress_screen.dart';
import 'dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/services/api_service.dart';
import '../onboarding_auth/auth_screen.dart';
import '../../providers/language_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../chatbot/chat_screen.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    DashboardScreen(
      onNavigateToTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const DisasterListScreen(),
    const PreparednessScreen(),
    const ProgressScreen(),
  ];

  void _showServerDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Server Settings'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'API Base URL',
              hintText: 'e.g. http://192.168.1.5:8000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ApiService.setBaseUrl(urlController.text.trim());
                context.read<UserProvider>().forceBackendSync();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('API URL set to: ${urlController.text}')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isDashboard = _currentIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        titleSpacing: 16,
        title: Row(
          children: [
            // Logo badge
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tealDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MUNNARIVU',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.tealDeep,
                  ),
                ),
                Text(
                  isDashboard
                      ? languageProvider.tr('Dashboard', 'முகப்பு')
                      : [
                          '',
                          languageProvider.tr('Learn', 'கற்க'),
                          languageProvider.tr('Preparedness', 'தயார்நிலை'),
                          languageProvider.tr('Progress', 'முன்னேற்றம்'),
                        ][_currentIndex],
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language toggle pill
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: () => context.read<LanguageProvider>().toggleLanguage(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.mintChip,
                foregroundColor: AppColors.tealDeep,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'EN | தமிழ்',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showServerDialog(context),
            icon: const Icon(Icons.settings_outlined, color: AppColors.tealDeep),
            tooltip: 'Server Settings',
          ),
          IconButton(
            onPressed: () {
              context.read<UserProvider>().resetProfile();
              context.read<LearningProgressProvider>().reset();
              context.read<AchievementProvider>().reset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: AppColors.tealDeep),
            tooltip: 'Switch User / Logout',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isDashboard) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
            );
          }
        },
        backgroundColor: isDashboard ? AppColors.tealDeep : AppColors.sosRed,
        foregroundColor: Colors.white,
        icon: Icon(isDashboard ? Icons.smart_toy : Icons.sos),
        label: Text(
          isDashboard
              ? languageProvider.tr('Munnarivu AI', 'முன்னறிவு AI')
              : languageProvider.tr('Emergency', 'அவசரம்'),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mintChip,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined,
                color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.home, color: AppColors.tealDeep),
            label: languageProvider.tr('Dashboard', 'முகப்பு'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined,
                color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.menu_book, color: AppColors.tealDeep),
            label: languageProvider.tr('Learn', 'கற்க'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.shield_outlined,
                color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.shield, color: AppColors.tealDeep),
            label: languageProvider.tr('Preparedness', 'தயார்நிலை'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined,
                color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.bar_chart, color: AppColors.tealDeep),
            label: languageProvider.tr('Progress', 'முன்னேற்றம்'),
          ),
        ],
      ),
    );
  }
}
