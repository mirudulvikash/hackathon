import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preparedness_provider.dart';
import '../../core/theme/app_theme.dart';

class PreparednessScreen extends StatelessWidget {
  const PreparednessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Pill-style scrollable tab bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textDark,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  indicator: BoxDecoration(),
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(24),
                  tabs: [
                    _pillTab('Emergency Kit', Icons.medical_information_outlined),
                    _pillTab('Campus Guide', Icons.map_outlined),
                    _pillTab('First-Aid', Icons.medical_services_outlined),
                    _pillTab("Do's & Don'ts", Icons.rule),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: const [
                    _EmergencyKitTab(),
                    _CampusGuideTab(),
                    _FirstAidTab(),
                    _DosAndDontsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillTab(String label, IconData icon) => Tab(
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tealDeep,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Emergency Kit tab
// ─────────────────────────────────────────────────────────────────────────────
class _EmergencyKitTab extends StatelessWidget {
  const _EmergencyKitTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PreparednessProvider>();
    final packed = provider.packedDisplayCount;
    final total = PreparednessProvider.itemMeta.length;
    final progress = provider.readinessProgress;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Readiness card
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
                                Icon(Icons.verified_outlined,
                                    size: 13, color: AppColors.tealDeep),
                                SizedBox(width: 5),
                                Text(
                                  'STANDARD PROTOCOL',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: AppColors.tealDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Emergency Kit',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ready for 72-hour survival resilience',
                            style: TextStyle(
                                fontSize: 12.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 7,
                              backgroundColor: AppColors.mintChip,
                              color: AppColors.tealDeep,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Text(
                      'Readiness Score',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    Spacer(),
                    Text(
                      'Packed',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.cardBg,
                    color: AppColors.tealDeep,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$packed of $total Packed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tip card
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hostel & Commuter Tip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealDeep,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Keep your backpack suspended on wall hooks above floor flood levels. Secure digital replicas of academic IDs on offline drives.',
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Essential Items header
          Row(
            children: [
              const Text(
                'Essential Items',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.tealMid,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final allPacked = packed == total;
                  context.read<PreparednessProvider>().toggleAll(!allPacked);
                },
                child: const Text(
                  'Toggle All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Checklist
          ...PreparednessProvider.itemMeta.map((meta) {
            final checked = provider.isPacked(meta.key);
            return _KitItemTile(
              meta: meta,
              checked: checked,
              onChanged: (v) =>
                  context.read<PreparednessProvider>().toggleItem(meta.key, v),
            );
          }),

          const SizedBox(height: 16),

          // Export / Share
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Kit manifest exported — $packed/$total items packed'),
                    backgroundColor: AppColors.tealDeep,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tealDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text(
                'Export / Share Kit Manifest',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitItemTile extends StatelessWidget {
  final KitItemMeta meta;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _KitItemTile({
    required this.meta,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = meta.urgent ? AppColors.sosRed : AppColors.tealDeep;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintChip.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon,
                size: 22, color: checked ? meta.color : AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        checked ? AppColors.textDark : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: meta.urgent
                            ? AppColors.sosRed.withValues(alpha: 0.12)
                            : AppColors.mintChip.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        meta.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meta.detail,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Checkbox
          Ink(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: checked
                  ? categoryColor
                  : AppColors.mintChip.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(!checked),
              child: checked
                  ? const Icon(Icons.check, size: 19, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campus Guide tab
// ─────────────────────────────────────────────────────────────────────────────
class _CampusGuideTab extends StatelessWidget {
  const _CampusGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _guideCard(context, Icons.meeting_room, 'Evacuation Routes',
            'Familiarize yourself with the primary and secondary evacuation routes from classrooms, labs, and dorms.'),
        _guideCard(context, Icons.place, 'Assembly Points',
            'Know the designated safe assembly area (usually open playgrounds or parking lots far from buildings).'),
        _guideCard(context, Icons.accessible, 'Assisting Peers',
            'Always assist differently-abled students and staff during evacuations. Ensure ramps and pathways are clear.'),
        _guideCard(context, Icons.science, 'Lab Protocols (Staff)',
            'Quickly shut down gas supplies, electrical equipment, and secure hazardous chemicals before evacuating.'),
        _guideCard(context, Icons.directions_walk, 'Avoid Stampedes',
            'Walk briskly, do not run. Use stairs instead of elevators. Keep calm to prevent panic.'),
      ],
    );
  }

  Widget _guideCard(
      BuildContext context, IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintChip.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: AppColors.tealDeep),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// First-Aid tab
// ─────────────────────────────────────────────────────────────────────────────
class _FirstAidTab extends StatelessWidget {
  const _FirstAidTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _aidCard(context, Icons.healing, 'Minor Burns',
            'Cool the burn under cool running water for 10-15 minutes. Do not apply ice or grease.'),
        _aidCard(context, Icons.bloodtype, 'Bleeding / Cuts',
            'Apply direct pressure with a clean cloth. Elevate the injured area if possible.'),
        _aidCard(context, Icons.accessibility_new, 'Fractures',
            'Immobilize the area. Do not try to realign the bone. Call for emergency medical help.'),
        _aidCard(context, Icons.thermostat, 'Heatstroke',
            'Move to a cool place, loosen clothes, and apply cool wet cloths. Sips of water if conscious. Call emergency!'),
        _aidCard(context, Icons.air, 'Smoke Inhalation',
            'Get to fresh air immediately. Keep calm and seek medical help if breathing is difficult.'),
      ],
    );
  }

  Widget _aidCard(
      BuildContext context, IconData icon, String title, String action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sosRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: AppColors.sosRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(action,
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Do's & Don'ts tab
// ─────────────────────────────────────────────────────────────────────────────
class _DosAndDontsTab extends StatelessWidget {
  const _DosAndDontsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mintChip.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.thumb_up, size: 20, color: AppColors.tealDeep),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Follow these actions to stay safe and avoid panic during any campus disaster event.",
                  style: TextStyle(
                      fontSize: 12.5, height: 1.4, color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(
          context,
          "DO'S",
          AppColors.tealDeep,
          Icons.check_circle,
          [
            'Stay calm and positive.',
            'Follow official instructions.',
            'Keep emergency kits ready.',
            'Help children & elderly.',
            'Turn off main utilities when leaving.',
          ],
        ),
        const SizedBox(height: 16),
        _section(
          context,
          "DON'TS",
          AppColors.sosRed,
          Icons.cancel,
          [
            'Spread rumors or panic.',
            'Use elevators during fires/earthquakes.',
            'Drink potentially contaminated water.',
            'Return to dangerous areas before clearance.',
            'Leave candles unattended.',
          ],
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, Color color,
      IconData icon, List<String> items) {
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
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon,
                        color: color.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textDark))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
