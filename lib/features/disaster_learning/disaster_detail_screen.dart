import 'package:flutter/material.dart';
import '../../models/disaster_model.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/achievement_provider.dart';
import '../quiz/quiz_screen.dart';
import '../../core/mock_data/quiz_data.dart';

class DisasterDetailScreen extends StatelessWidget {
  final DisasterModel disaster;
  final int initialTabIndex;

  const DisasterDetailScreen({super.key, required this.disaster, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(disaster.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Before & During'),
              Tab(text: 'After & Precautions'),
              Tab(text: 'Take Action'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildBeforeDuringTab(context),
            _buildAfterPrecautionsTab(context),
            _buildTakeActionTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'What is it?'),
          _buildText(context, disaster.whatIsIt),
          const SizedBox(height: 24),
          
          _buildSectionTitle(context, 'Causes'),
          _buildBulletList(context, disaster.causes),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Warning Signs'),
          _buildBulletList(context, disaster.warningSigns),
        ],
      ),
    );
  }

  Widget _buildBeforeDuringTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Before Actions (Preparedness)'),
          _buildBulletCards(context, disaster.beforeActions, Icons.inventory_2_outlined),
          const SizedBox(height: 24),
          
          _buildSectionTitle(context, 'During Actions (Survival)'),
          _buildBulletCards(context, disaster.duringActions, Icons.directions_run),
        ],
      ),
    );
  }

  Widget _buildAfterPrecautionsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'After Actions (Recovery)'),
          _buildBulletCards(context, disaster.afterActions, Icons.handyman_outlined),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'General Safety Precautions'),
          _buildBulletCards(context, disaster.safetyPrecautions, Icons.health_and_safety_outlined),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Common Mistakes to Avoid', color: Colors.redAccent),
          ...disaster.mistakesToAvoid.map((mistake) => Card(
            color: Theme.of(context).colorScheme.errorContainer,
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
              title: Text(
                mistake,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTakeActionTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'You\'re ready to take the next step.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              context.read<LearningProgressProvider>().markTopicAsRead(disaster.id);
              final userId = context.read<UserProvider>().userId ?? 1;
              final newlyUnlocked = await context.read<AchievementProvider>().logActivity(userId, disasterId: disaster.id, activityType: 'lesson');
              
              if (!context.mounted) return;
              if (newlyUnlocked.isNotEmpty) {
                final ach = newlyUnlocked.first;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Achievement Unlocked: ${ach['title']}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${disaster.name} marked as Read!')),
                );
              }
            },
            icon: const Icon(Icons.done_all),
            label: const Text('Mark as Read'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              final questions = mockQuizQuestions.where((q) => q.disasterId == disaster.id).toList();
              if (questions.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      disasterId: disaster.id,
                      topicName: disaster.name,
                      questions: questions,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No quiz available for this topic yet!')),
                );
              }
            },
            icon: const Icon(Icons.quiz),
            label: const Text('Take Topic Quiz'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }

  // Helper UI Builders
  Widget _buildSectionTitle(BuildContext context, String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBulletCards(BuildContext context, List<String> items, IconData iconData) {
    return Column(
      children: items.map((item) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Icon(iconData, color: Theme.of(context).colorScheme.secondary),
            title: Text(item),
          ),
        );
      }).toList(),
    );
  }
}
