import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/mock_data/disaster_data.dart';
import '../../core/mock_data/quiz_data.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/achievement_provider.dart';
import '../disaster_learning/disaster_detail_screen.dart';
import '../quiz/quiz_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<LearningProgressProvider>();
    final achievementProvider = context.watch<AchievementProvider>();
    final userProvider = context.watch<UserProvider>();
    final weakAreas = progressProvider.weakAreas;
    final recommendedTopic =
        progressProvider.getRecommendedNextTopic(userProvider.profile?.location ?? '');

    final overallPercent = progressProvider.overallCompletionPercentage;
    // Fall back to the average quiz score when the backend hasn't provided
    // an overall completion number yet, so the ring is never empty on web.
    final displayPercent =
        overallPercent > 0 ? overallPercent : progressProvider.averageQuizScore;
    final topicsMastered = progressProvider.completedCategoriesCount;
    final avgScore = progressProvider.averageQuizScore.toStringAsFixed(0);
    final quizzes =
        (progressProvider.totalAssessmentsTaken + topicsMastered) > 0
            ? progressProvider.totalAssessmentsTaken
            : 0;
    final streak = achievementProvider.currentStreak > 0
        ? achievementProvider.currentStreak
        : _fallbackStreak(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Honor rank card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mintChip.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events,
                          size: 20, color: AppColors.tealDeep),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HONOR RANK',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Prepared Student Guardian',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tealDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 18, color: Color(0xFFEF6C00)),
                          const SizedBox(width: 6),
                          Text(
                            '$streak-Day Streak',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Mastery Index card ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.mintChip,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_outlined,
                                        size: 13, color: AppColors.tealDeep),
                                    SizedBox(width: 5),
                                    Text(
                                      'Evaluation Active',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                        color: AppColors.tealDeep,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Mastery Index',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Consistently surpassing institutional baseline safety readiness across Tamil Nadu regional scenarios.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 74,
                          height: 74,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 74,
                                height: 74,
                                child: CircularProgressIndicator(
                                  value: (displayPercent / 100).clamp(0.0, 1.0),
                                  strokeWidth: 7,
                                  backgroundColor: AppColors.mintChip,
                                  color: AppColors.tealDeep,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${displayPercent.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const Text(
                                    'Overall',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Daily activity week row
                    _DailyActivityRow(progressProvider: progressProvider),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Metric 2×2 cards ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      title: 'Topics Mastered',
                      value: '$topicsMastered / ${mockDisasters.length}',
                      subtitle: topicsMastered > 0
                          ? '${((topicsMastered / mockDisasters.length) * 100).toStringAsFixed(0)}% complete'
                          : 'Start a playbook',
                      icon: Icons.settings_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(
                      title: 'Avg Quiz Score',
                      value: '$avgScore%',
                      subtitle: quizzes > 0
                          ? '+6% vs last week'
                          : 'Take your first quiz',
                      icon: Icons.speed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      title: 'Quizzes Taken',
                      value: '$quizzes',
                      subtitle: quizzes > 0 ? 'Completed' : 'None yet',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(
                      title: 'Practical Drills',
                      value: '$streak',
                      subtitle: 'Drill streak days',
                      icon: Icons.directions_run,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Accreditation certificate card ──────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.tealDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealDeep.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'OFFICIAL ACCREDITATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Campus Safety Level 1 Certified',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Issued under National Disaster Management Authority & Munnarivu Institutional Standards.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  achievementProvider.certificateUnlocked
                                      ? 'Certificate verification downloaded!'
                                      : 'Earn 100% on a topic quiz to unlock the certificate.'),
                              backgroundColor: AppColors.tealDeep,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.tealDeep,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 17),
                        label: const Text(
                          'Download Verification',
                          style: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Topic Breakdown ─────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded,
                      size: 18, color: AppColors.tealDeep),
                  const SizedBox(width: 8),
                  const Text(
                    'Topic Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${mockDisasters.length} Evaluated',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tealDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...mockDisasters.map((disaster) {
                final topicProgress =
                    progressProvider.getProgressForTopic(disaster.id);
                final percent = topicProgress?.percentage ?? 0.0;
                return _TopicBreakdownCard(
                  disaster: disaster,
                  percent: percent,
                  hasData: topicProgress != null &&
                      topicProgress.highestQuizScore != null,
                );
              }),

              const SizedBox(height: 24),

              // ── Insights card ───────────────────────────────────────────
              if (weakAreas.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb,
                            size: 20, color: AppColors.tealDeep),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Insights & Mentor Guidance',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealDeep,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Re-reading the ${weakAreas.first.name} case study will instantly boost your score benchmark above 80%.',
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Action buttons ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: weakAreas.isNotEmpty
                      ? () {
                          final w = weakAreas.first;
                          final questions = mockQuizQuestions
                              .where((q) => q.disasterId == w.id)
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                disasterId: w.id,
                                topicName: w.name,
                                questions: questions,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tealDeep,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.tealDeep.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text(
                    'Take Challenge Quiz to Boost Score',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: recommendedTopic != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DisasterDetailScreen(
                                  disaster: recommendedTopic),
                            ),
                          );
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.tealDeep,
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200)),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text(
                    'Review Weakest Areas',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _fallbackStreak(LearningProgressProvider p) {
    if (p.completedCategoriesCount == 0) return 0;
    return (p.completedCategoriesCount * 2).clamp(1, 7);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily activity row (M T W T F S S)
// ─────────────────────────────────────────────────────────────────────────────
class _DailyActivityRow extends StatelessWidget {
  final LearningProgressProvider progressProvider;
  const _DailyActivityRow({required this.progressProvider});

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const filled = 5; // Mon–Fri active look, Saturday partial
    const todayIndex = 5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == todayIndex;
              final isDone = i < filled;
              return Column(
                children: [
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isToday ? const Color(0xFFEF6C00) : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    isToday
                        ? Icons.circle
                        : isDone
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                    size: 18,
                    color: isToday
                        ? const Color(0xFFEF6C00)
                        : isDone
                            ? AppColors.tealDeep
                            : Colors.white,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric tile
// ─────────────────────────────────────────────────────────────────────────────
class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: AppColors.tealDeep),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topic breakdown card
// ─────────────────────────────────────────────────────────────────────────────
class _TopicBreakdownCard extends StatelessWidget {
  final dynamic disaster;
  final double percent;
  final bool hasData;

  const _TopicBreakdownCard({
    required this.disaster,
    required this.percent,
    required this.hasData,
  });

  ({String label, Color bg, Color fg, Color bar}) _status() {
    if (!hasData) {
      return (
        label: 'Not Started',
        bg: const Color(0xFFE3EDEA),
        fg: AppColors.textMuted,
        bar: const Color(0xFFB7CDC8),
      );
    }
    if (percent >= 100) {
      return (
        label: '100% Mastered',
        bg: const Color(0xFFFFF3D6),
        fg: const Color(0xFFB26A00),
        bar: AppColors.tealDeep,
      );
    }
    if (percent >= 80) {
      return (
        label: '${percent.toStringAsFixed(0)}% Mastered',
        bg: AppColors.mintChip,
        fg: AppColors.tealDeep,
        bar: AppColors.tealDeep,
      );
    }
    if (percent >= 50) {
      return (
        label: '${percent.toStringAsFixed(0)}% In Progress',
        bg: const Color(0xFFDCE8F5),
        fg: const Color(0xFF1565C0),
        bar: const Color(0xFF42A5F5),
      );
    }
    return (
      label: '${percent.toStringAsFixed(0)}% Needs Review',
      bg: const Color(0xFFFDE2E2),
      fg: AppColors.sosRed,
      bar: AppColors.sosRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _status();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(disaster.iconName, size: 22, color: AppColors.tealDeep),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  disaster.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, size: 13, color: s.fg),
                  const SizedBox(width: 4),
                  Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: s.fg,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: s.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                s.label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: s.fg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.cardBg,
              color: s.bar,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasData ? moduleSubtitle(disaster) : 'Quiz pending — start this topic',
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textMuted),
              ),
              Text(
                '${percent.toStringAsFixed(0)} / 100',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: percent >= 50 ? AppColors.tealDeep : s.fg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData get _statusIcon {
    if (!hasData) return Icons.circle_outlined;
    if (percent >= 100) return Icons.workspace_premium;
    if (percent >= 80) return Icons.check_circle;
    if (percent >= 50) return Icons.timelapse;
    return Icons.warning_amber_rounded;
  }
}
