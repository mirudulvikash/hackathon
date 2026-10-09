import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/services/api_service.dart';
import 'certificate_dialog.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  void _showCertificate(BuildContext context, int userId) async {
    final certData = await ApiService.getCertificate(userId);
    if (certData != null && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => CertificateDialog(certificateData: certData),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load certificate data. Please check backend connection.')),
      );
    }
  }

  void _simulateDay(BuildContext context, int userId, int offsetDays) async {
    final simulatedDate = DateTime.now().add(Duration(days: offsetDays));
    final dateStr = "${simulatedDate.year}-${simulatedDate.month.toString().padLeft(2, '0')}-${simulatedDate.day.toString().padLeft(2, '0')}";
    
    final newlyUnlocked = await context.read<AchievementProvider>().logActivity(
      userId,
      disasterId: 'd1',
      activityType: 'simulated_lesson',
      customDate: dateStr,
    );
    
    if (context.mounted && newlyUnlocked.isNotEmpty) {
      final ach = newlyUnlocked.first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Achievement Unlocked: ${ach['title']}!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final achProvider = context.watch<AchievementProvider>();
    final userProvider = context.watch<UserProvider>();
    final lang = context.watch<LanguageProvider>();
    final theme = Theme.of(context);
    final userId = userProvider.userId ?? 1;

    final streak = achProvider.currentStreak;
    final totalDays = achProvider.totalActiveDays;
    final achievements = achProvider.achievements;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      lang.tr('Your Achievements', 'உங்கள் சாதனைகள்'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Test Milestone Simulation',
                  onSelected: (days) => _simulateDay(context, userId, days),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0, child: Text("Simulate Day 1 (First Step)")),
                    const PopupMenuItem(value: 6, child: Text("Simulate Day 7 (Silver Badge)")),
                    const PopupMenuItem(value: 29, child: Text("Simulate Day 30 (Safety Champion)")),
                    const PopupMenuItem(value: 99, child: Text("Simulate Day 100 (Disaster Champion)")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Streak & Days Stats Header
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$streak ${lang.tr("Days Streak", "நாட்கள் தொடர்ச்சி")}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              lang.tr("Active Learning", "செயலில் உள்ள கற்றல்"),
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalDays ${lang.tr("Total Days", "மொத்த நாட்கள்")}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              lang.tr("Lessons Completed", "பாடங்கள் முடிந்தது"),
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badges Grid / List
            _buildBadgeItem(
              context,
              title: lang.tr("First Step", "முதல் அடி"),
              reqText: lang.tr("First lesson completed", "முதல் பாடம் முடிந்தது"),
              icon: Icons.menu_book,
              color: Colors.blue,
              currentProgress: totalDays >= 1 ? 1 : totalDays,
              maxProgress: 1,
              unlocked: _isUnlocked(achievements, 'first_step'),
            ),
            const SizedBox(height: 10),
            
            _buildBadgeItem(
              context,
              title: lang.tr("Silver Badge", "வெள்ளி பேட்ஜ்"),
              reqText: lang.tr("7 consecutive learning days", "7 நாட்கள் தொடர்ச்சியான கற்றல்"),
              icon: Icons.workspace_premium,
              color: Colors.blueGrey,
              currentProgress: streak >= 7 ? 7 : streak,
              maxProgress: 7,
              unlocked: _isUnlocked(achievements, 'silver_badge'),
            ),
            const SizedBox(height: 10),

            _buildBadgeItem(
              context,
              title: lang.tr("Safety Champion", "பாதுகாப்பு சாம்பியன்"),
              reqText: lang.tr("30 consecutive learning days", "30 நாட்கள் தொடர்ச்சியான கற்றல்"),
              icon: Icons.shield,
              color: Colors.orange.shade800,
              currentProgress: streak >= 30 ? 30 : streak,
              maxProgress: 30,
              unlocked: _isUnlocked(achievements, 'safety_champion'),
            ),
            const SizedBox(height: 10),

            _buildBadgeItem(
              context,
              title: lang.tr("Disaster Preparedness Champion", "பேரிடர் ஆயத்த சாம்பியன்"),
              reqText: lang.tr("100 consecutive learning days + Official Certificate", "100 நாட்கள் தொடர்ச்சியான கற்றல் + சான்றிதழ்"),
              icon: Icons.military_tech,
              color: Colors.amber.shade700,
              currentProgress: streak >= 100 ? 100 : streak,
              maxProgress: 100,
              unlocked: _isUnlocked(achievements, 'champion_100'),
            ),

            if (achProvider.certificateUnlocked || _isUnlocked(achievements, 'champion_100')) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showCertificate(context, userId),
                  icon: const Icon(Icons.card_membership),
                  label: Text(lang.tr("View 100-Day Champion Certificate", "100 நாள் சாம்பியன் சான்றிதழைப் பார்")),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isUnlocked(List<Map<String, dynamic>> achievements, String key) {
    return achievements.any((a) => a['badge_key'] == key && a['unlocked'] == true);
  }

  Widget _buildBadgeItem(
    BuildContext context, {
    required String title,
    required String reqText,
    required IconData icon,
    required Color color,
    required int currentProgress,
    required int maxProgress,
    required bool unlocked,
  }) {
    final progressRatio = (currentProgress / maxProgress).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.4) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: unlocked ? color : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? icon : Icons.lock,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: unlocked ? Colors.black87 : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      unlocked ? "Unlocked" : "$currentProgress / $maxProgress days",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reqText,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(unlocked ? color : Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
