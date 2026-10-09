import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data/disaster_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/disaster_model.dart';
import '../../providers/user_provider.dart';
import 'disaster_detail_screen.dart';

class DisasterListScreen extends StatefulWidget {
  const DisasterListScreen({super.key});

  @override
  State<DisasterListScreen> createState() => _DisasterListScreenState();
}

class _DisasterListScreenState extends State<DisasterListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<DisasterModel> _getFilteredDisasters(String userLocation) {
    return mockDisasters.where((disaster) {
      final matchesSearch =
          disaster.name.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      if (_selectedFilter == 'Natural Disasters') {
        matchesFilter = disaster.category == 'Natural';
      } else if (_selectedFilter == 'Man-Made Disasters') {
        matchesFilter = disaster.category == 'Man-Made';
      } else if (_selectedFilter == 'Recommended') {
        matchesFilter = disaster.relevantLocations.contains(userLocation);
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = context.watch<UserProvider>().profile?.location ?? '';
    final filteredList = _getFilteredDisasters(userLocation);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search disaster topics, safety drills, guides...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textMuted, size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.tealMid),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // Filter chips: All (6) / Natural Disasters (4) / Man-Made (2) / Recommended
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip('All (${mockDisasters.length})', 'All'),
                  _filterChip(
                      'Natural Disasters (${_countByCategory('Natural')})',
                      'Natural Disasters'),
                  _filterChip(
                      'Man-Made Disasters (${_countByCategory('Man-Made')})',
                      'Man-Made Disasters'),
                  _filterChip('Recommended', 'Recommended'),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text('No disaster modules found.',
                          style: TextStyle(color: AppColors.textMuted)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _ModuleCard(disaster: filteredList[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _countByCategory(String category) =>
      mockDisasters.where((d) => d.category == category).length;

  Widget _filterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedFilter = value),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textMuted,
        ),
        selectedColor: AppColors.tealDeep,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final DisasterModel disaster;
  const _ModuleCard({required this.disaster});

  bool get _isManMade => disaster.category == 'Man-Made';

  @override
  Widget build(BuildContext context) {
    final isRecommended =
        disaster.relevantLocations.contains(context.read<UserProvider>()
                .profile
                ?.location ??
            '');

    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(20),
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
            // Image banner with badges
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (disaster.imagePath != null)
                    Image.asset(disaster.imagePath!, fit: BoxFit.cover)
                  else
                    Container(
                      color: AppColors.imagePlaceholder,
                      child: Icon(disaster.iconName,
                          size: 48, color: AppColors.tealMid),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        _OverlayBadge(
                          icon: _isManMade
                              ? Icons.engineering
                              : Icons.landscape_outlined,
                          label: disaster.category,
                        ),
                        const SizedBox(width: 6),
                        if (isRecommended)
                          const _OverlayBadge(
                            icon: Icons.star,
                            label: 'Recommended',
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tealDeep.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            '${moduleCount(disaster)} Modules',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleTitle(disaster),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    longDescriptionFor(disaster.id).isNotEmpty
                        ? longDescriptionFor(disaster.id)
                        : disaster.shortDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 14, color: AppColors.textDark),
                      const SizedBox(width: 6),
                      Text(
                        'Est. ${moduleMinutes(disaster)} mins',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: AppColors.tealDeep,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DisasterDetailScreen(disaster: disaster)),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start Module',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward,
                                    size: 15, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _OverlayBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isCritical = label == 'Critical';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.badgeCriticalBg
            : AppColors.badgeNaturalBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: isCritical ? Colors.white : AppColors.badgeNaturalFg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCritical ? Colors.white : AppColors.badgeNaturalFg,
            ),
          ),
        ],
      ),
    );
  }
}
