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

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    DisasterListScreen(),
    PreparednessScreen(),
    ProgressScreen(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Munnarivu'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showServerDialog(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Server Settings',
          ),
          IconButton(
            onPressed: () {
              context.read<UserProvider>().resetProfile();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Switch User / Logout',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
              );
            },
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            tooltip: 'Emergency Quick Guide',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton.extended(
         onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
            );
         },
         backgroundColor: Theme.of(context).colorScheme.errorContainer,
         foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
         icon: const Icon(Icons.sos),
         label: const Text('Emergency'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Preparedness',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
