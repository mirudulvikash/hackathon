import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../core/mock_data/disaster_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/disaster_model.dart';
import '../disaster_learning/disaster_detail_screen.dart';
import '../emergency_response/emergency_guide_screen.dart';
import '../achievements/achievements_section.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int)? onNavigateToTab;
  const DashboardScreen({super.key, this.onNavigateToTab});

  void _showLocationSwitcher(BuildContext context) {
    final List<String> locations = [
      'Coimbatore', 'Chennai', 'Nilgiris', 'Madurai', 'Tiruchirappalli', 'Salem', 'Kanyakumari'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    'Select Your Location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Get location-aware emergency alerts and personalized disaster preparedness guides.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
                for (final loc in locations)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.mintChip.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_city, color: AppColors.teal),
                    ),
                    title: Text(loc, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    final theme = Theme.of(context);

    final topicsMastered = progressProvider.completedCategoriesCount;
    final avgScore = progressProvider.averageQuizScore.toStringAsFixed(0);

    final name = userProfile?.name.isNotEmpty == true ? userProfile!.name : 'Demo Student';
    final location = userProfile?.location.isNotEmpty == true ? userProfile!.location : 'Coimbatore';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Greeting / location card ──────────────────────────────
                    _buildGreetingCard(context, name, location, theme),
                    const SizedBox(height: 16),

                    // ── Instant SOS banner ────────────────────────────────────
                    _buildSosBanner(context, theme),
                    const SizedBox(height: 16),

                    // ── In-progress module ────────────────────────────────────
                    _buildInProgressCard(context, theme, progressProvider),
                    const SizedBox(height: 24),

                    // ── Disaster Playbooks grid ───────────────────────────────
                    _buildPlaybooksSection(context, theme),
                    const SizedBox(height: 24),

                    // ── Preparedness metrics ──────────────────────────────────
                    _buildMetricsSection(theme, topicsMastered, avgScore),
                    const SizedBox(height: 24),

                    // ── Campus library ────────────────────────────────────────
                    _buildLibraryCard(context, theme),
                    const SizedBox(height: 24),

                    // ── Achievements (kept from existing app) ─────────────────
                    const AchievementsSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Greeting / location card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGreetingCard(BuildContext context, String name, String location, ThemeData theme) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TAMIL NADU SAFETY PORTAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'வணக்கம், $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"Preparedness turns fear into safety"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.mintChip,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.tealDeep, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.tealDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        'Coastal Moderate Risk',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showLocationSwitcher(context),
                  icon: const Icon(Icons.tune, size: 14, color: AppColors.tealDeep),
                  label: const Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tealDeep,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Instant SOS banner
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSosBanner(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sosRed, AppColors.sosRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.sosRed.withValues(alpha: 0.35),
            blurRadius: 14,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sos, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'INSTANT SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Emergency Guidance & Quick SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '1-tap access to campus evacuation paths, siren triggers, and first responders.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.sosRed,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text(
                'Open Emergency Protocol',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // In-progress module card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildInProgressCard(BuildContext context, ThemeData theme, LearningProgressProvider progressProvider) {
    final nextTopic = progressProvider.getRecommendedNextTopic(
        context.read<UserProvider>().profile?.location ?? '');

    if (nextTopic == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Icon(Icons.auto_stories_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text(
              'No module in progress',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Open a Disaster Playbook below to begin.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final disaster = nextTopic;
    final topicProgress = progressProvider.getProgressForTopic(disaster.id);
    final double percentageRaw = (topicProgress?.percentage ?? 0.0);
    final double percentage = percentageRaw / 100.0;

    int targetTabIndex = 0;
    if (percentageRaw > 0 && percentageRaw < 50) {
      targetTabIndex = 1;
    } else if (percentageRaw >= 50 && percentageRaw < 100) {
      targetTabIndex = 3;
    }

    int minsLeft = (moduleMinutes(disaster) * (1 - percentage)).round().clamp(1, 999);

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.tealDeep),
              const SizedBox(width: 6),
              const Text(
                'IN PROGRESS MODULE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.tealDeep,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$minsLeft mins left',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: disaster.imagePath != null
                      ? Image.asset(disaster.imagePath!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.imagePlaceholder,
                          child: const Icon(Icons.shield, color: AppColors.tealMid),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moduleTitle(disaster),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit 3: ${moduleSubtitle(disaster)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Curriculum Mastery',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                '${percentageRaw.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tealDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.cardBg,
              color: AppColors.tealDeep,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tealDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DisasterDetailScreen(
                      disaster: disaster,
                      initialTabIndex: targetTabIndex,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(
                percentageRaw == 0 ? 'Start Learning' : 'Resume Learning',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Disaster Playbooks grid
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPlaybooksSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disaster Playbooks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Standard Operating Procedures by Type',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${mockDisasters.length} Modules',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.tealDeep,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: mockDisasters.length,
          itemBuilder: (context, index) =>
              _PlaybookCard(disaster: mockDisasters[index]),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Preparedness metrics
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMetricsSection(ThemeData theme, int topicsMastered, String avgScore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preparedness Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.task_alt,
                value: '$topicsMastered',
                label: 'Mastered',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.quiz_outlined,
                value: '$avgScore%',
                label: 'Quiz Score',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department,
                value: '4 Days',
                label: 'Drill Streak',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Campus library card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLibraryCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintChip.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.tealDeep, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMPUS LIBRARY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Disaster Manuals & Blueprints',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Download offline evacuation guides & maps',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Assembly zones map row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, size: 18, color: AppColors.tealDeep),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Campus Assembly Zones Map (PDF)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.download_rounded, size: 18, color: AppColors.tealDeep),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(1); // Navigate to Learn tab
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.mintChip,
                foregroundColor: AppColors.tealDeep,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explore Library & Blueprints',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PlaybookCard extends StatelessWidget {
  final DisasterModel disaster;
  const _PlaybookCard({required this.disaster});

  bool get _isManMade => disaster.category == 'Man-Made';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DisasterDetailScreen(disaster: disaster)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (disaster.imagePath != null)
                    Image.asset(disaster.imagePath!, fit: BoxFit.cover)
                  else
                    Container(
                      color: AppColors.imagePlaceholder,
                      child: Icon(disaster.iconName,
                          size: 36, color: AppColors.tealMid),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isManMade
                            ? AppColors.badgeManMadeBg.withValues(alpha: 0.95)
                            : AppColors.badgeNaturalBg.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        disaster.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isManMade
                              ? AppColors.badgeManMadeFg
                              : AppColors.badgeNaturalFg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disaster.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        moduleSubtitle(disaster),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DisasterDetailScreen(disaster: disaster)),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.mintChip,
                          foregroundColor: AppColors.tealDeep,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.mintChip,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.tealDeep),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
