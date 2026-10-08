import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/mock_data/disaster_data.dart';
import '../disaster_learning/disaster_detail_screen.dart';
import '../quiz/quiz_screen.dart';
import '../../core/mock_data/quiz_data.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<LearningProgressProvider>();
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    
    final overallPercent = progressProvider.overallCompletionPercentage;
    final weakAreas = progressProvider.weakAreas;
    final recommendedTopic = progressProvider.getRecommendedNextTopic(userProvider.profile?.location ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance & Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Summary Card
              Card(
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Overall Mastery', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    overallPercent.toStringAsFixed(0),
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      height: 1,
                                    ),
                                  ),
                                  Text('%', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  '${progressProvider.streakDays} Day Streak',
                                  style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: overallPercent / 100,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(context, '${progressProvider.completedCategoriesCount}', 'Topics Mastered'),
                          _buildStatColumn(context, '${progressProvider.averageQuizScore.toStringAsFixed(0)}%', 'Avg Quiz Score'),
                          _buildStatColumn(context, '${progressProvider.totalAssessmentsTaken}', 'Quizzes Taken'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weak Areas & Next Steps
              if (weakAreas.isNotEmpty || recommendedTopic != null) ...[
                Text('Areas to Improve & Next Steps', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                if (weakAreas.isNotEmpty)
                  Card(
                    color: theme.colorScheme.errorContainer,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_down, color: theme.colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Topics requiring review (< 60%)', 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onErrorContainer)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...weakAreas.map((w) {
                            final p = progressProvider.getProgressForTopic(w.id);
                            final score = ((p!.highestQuizScore! / p.totalQuizQuestions!) * 100).toStringAsFixed(0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('• ${w.name} (Scored $score%)'),
                                  OutlinedButton(
                                    onPressed: () {
                                       final questions = mockQuizQuestions.where((q) => q.disasterId == w.id).toList();
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
                                         disasterId: w.id, topicName: w.name, questions: questions
                                       )));
                                    },
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                    ),
                                    child: const Text('Retake Quiz'),
                                  )
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),

                if (recommendedTopic != null)
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(recommendedTopic.iconName, color: theme.colorScheme.onSecondaryContainer, size: 36),
                      title: Text('Recommended Next: ${recommendedTopic.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Based on your location and progress.'),
                      trailing: FilledButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DisasterDetailScreen(disaster: recommendedTopic)));
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Topic-wise Mastery List
              Text('Topic-wise Mastery', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              ...mockDisasters.map((disaster) {
                final topicProgress = progressProvider.getProgressForTopic(disaster.id);
                final percent = topicProgress?.percentage ?? 0.0;
                
                String statusLabel = 'Not Started';
                Color statusColor = Colors.grey;
                IconData statusIcon = Icons.circle_outlined;
                
                if (percent == 100.0) {
                  statusLabel = 'Completed ✓';
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                } else if (percent > 0) {
                  statusLabel = 'In Progress';
                  statusColor = Colors.blue;
                  statusIcon = Icons.pending;
                }

                String scoreLabel = 'No Quiz';
                if (topicProgress?.highestQuizScore != null) {
                  final score = ((topicProgress!.highestQuizScore! / topicProgress.totalQuizQuestions!) * 100).toStringAsFixed(0);
                  scoreLabel = 'Best: $score%';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(disaster.iconName, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(disaster.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: statusColor.withValues(alpha: 0.1),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Row(
                               children: [
                                 Icon(statusIcon, color: statusColor, size: 14),
                                 const SizedBox(width: 4),
                                 Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                               ],
                             ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${percent.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                            Text(scoreLabel, style: theme.textTheme.bodySmall),
                          ],
                        ),
                        if (disaster.recommendationReason != null)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: disaster.recommendationReason!.toLowerCase().contains('review') 
                                ? Colors.red.withValues(alpha: 0.1) 
                                : theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  disaster.recommendationReason!.toLowerCase().contains('review') 
                                    ? Icons.warning_amber_rounded 
                                    : Icons.info_outline, 
                                  size: 16, 
                                  color: disaster.recommendationReason!.toLowerCase().contains('review') 
                                    ? Colors.red[800] 
                                    : theme.colorScheme.onPrimaryContainer
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    disaster.recommendationReason!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: disaster.recommendationReason!.toLowerCase().contains('review') 
                                        ? Colors.red[800] 
                                        : theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
