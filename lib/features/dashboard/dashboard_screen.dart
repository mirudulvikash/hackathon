import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../core/mock_data/disaster_data.dart';
import '../disaster_learning/disaster_detail_screen.dart';
import '../emergency_response/emergency_guide_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showLocationSwitcher(BuildContext context) {
    final List<String> locations = [
      'Coimbatore', 'Chennai', 'Nilgiris', 'Madurai', 'Tiruchirappalli', 'Salem', 'Kanyakumari'
    ];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Change Focus Area',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Explore educational content localized for different regions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                for (final loc in locations)
                  ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(loc),
                    onTap: () {
                      context.read<UserProvider>().updateLocation(loc);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final progressProvider = context.watch<LearningProgressProvider>();
    final userProfile = userProvider.profile;
    final recommended = userProvider.recommendedDisasters;
    final theme = Theme.of(context);
    
    final topicsRead = progressProvider.completedCategoriesCount;
    final totalTopics = mockDisasters.length;
    final avgScore = progressProvider.averageQuizScore.toStringAsFixed(0);

    // Safe fallbacks
    final name = userProfile?.name.isNotEmpty == true ? userProfile!.name : 'Learner';
    final role = userProfile?.role.isNotEmpty == true ? userProfile!.role : 'Student';
    final location = userProfile?.location.isNotEmpty == true ? userProfile!.location : 'Select Location';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning, $name 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                role,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: userProvider.isBackendConnected ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: userProvider.isBackendConnected ? Colors.green : Colors.amber,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                userProvider.isBackendConnected ? '● Live Backend Connected' : '● Offline Local Mode',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: userProvider.isBackendConnected ? Colors.green[800] : Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showLocationSwitcher(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSecondaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Learn what matters for your area.',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),

              // Section 1: Recommended for Region
              Text(
                'Recommended for $location',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: recommended.isEmpty
                    ? Center(child: Text('No specific recommendations found for $location.'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        itemBuilder: (context, index) {
                          final disaster = recommended[index];
                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DisasterDetailScreen(disaster: disaster)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(disaster.iconName, size: 32, color: theme.colorScheme.primary),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceContainerHighest,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.arrow_forward_ios, size: 12),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        disaster.name,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      if (disaster.recommendationReason != null)
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: disaster.recommendationReason!.contains('Retake') ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              disaster.recommendationReason!,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontSize: 10,
                                                color: disaster.recommendationReason!.contains('Retake') ? Colors.red[800] : theme.colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      else
                                        Flexible( // <-- FIXED renderflex overflow risk
                                          child: Text(
                                            'Region: $location',
                                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 32),

              // Section 2: Continue Learning Card
              Text(
                'Continue Learning',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.water, color: theme.colorScheme.onTertiaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flood Preparedness',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.6,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: theme.colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4),
                            Text('60% completed', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Section 3: Overall Progress Summary Card
              Text(
                'Your Progress',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.local_library, size: 32, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text('$topicsRead / $totalTopics', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Topics assessed', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.workspace_premium, size: 32, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text('$avgScore%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Quiz Avg', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Section 4: Quick Access Banner
              Card(
                color: theme.colorScheme.primary,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.explore, color: theme.colorScheme.onPrimary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Educational & Emergency Access',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have full control. Explore topics from all regions, or access the active SOS guidance protocols instantly.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
                          );
                        },
                        icon: Icon(Icons.sos, color: theme.colorScheme.onError),
                        style: FilledButton.styleFrom(
                           backgroundColor: theme.colorScheme.error,
                           foregroundColor: theme.colorScheme.onError,
                        ),
                        label: const Text('Emergency Response Guide'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Use the Bottom Nav to visit the Learn tab!')),
                           );
                        },
                        icon: Icon(Icons.menu_book, color: theme.colorScheme.onPrimary),
                        style: OutlinedButton.styleFrom(
                           foregroundColor: theme.colorScheme.onPrimary,
                           side: BorderSide(color: theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                        ),
                        label: const Text('View All Categories'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
