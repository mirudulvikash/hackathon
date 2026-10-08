import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preparedness_provider.dart';

class PreparednessScreen extends StatelessWidget {
  const PreparednessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Emergency Kit'),
              Tab(text: 'Campus Guide'),
              Tab(text: 'First-Aid'),
              Tab(text: 'Do\'s & Don\'ts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _EmergencyKitTab(),
                const _CampusGuideTab(),
                const _FirstAidTab(),
                const _DosAndDontsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyKitTab extends StatelessWidget {
  const _EmergencyKitTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PreparednessProvider>();
    final completed = provider.completedItems;
    final total = provider.totalItems;
    final progress = provider.readinessProgress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Your Kit Readiness: $completed/$total items ready',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: provider.kitItems.length,
              itemBuilder: (context, index) {
                final key = provider.kitItems.keys.elementAt(index);
                final value = provider.kitItems[key]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    title: Text(
                      key,
                      style: TextStyle(
                        fontWeight: value ? FontWeight.bold : FontWeight.normal,
                        decoration: value ? TextDecoration.lineThrough : null,
                        color: value ? Colors.grey : null,
                      ),
                    ),
                    value: value,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        context.read<PreparednessProvider>().toggleItem(key, newValue);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusGuideTab extends StatelessWidget {
  const _CampusGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildGuideCard(context, Icons.meeting_room, 'Evacuation Routes', 
          'Familiarize yourself with the primary and secondary evacuation routes from classrooms, labs, and dorms.'),
        _buildGuideCard(context, Icons.place, 'Assembly Points', 
          'Know the designated safe assembly area (usually open playgrounds or parking lots far from buildings).'),
        _buildGuideCard(context, Icons.accessible, 'Assisting Peers', 
          'Always assist differently-abled students and staff during evacuations. Ensure ramps and pathways are clear.'),
        _buildGuideCard(context, Icons.science, 'Lab Protocols (Staff)', 
          'Quickly shut down gas supplies, electrical equipment, and secure hazardous chemicals before evacuating.'),
        _buildGuideCard(context, Icons.directions_walk, 'Avoid Stampedes', 
          'Walk briskly, do not run. Use stairs instead of elevators. Keep calm to prevent panic.'),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, IconData icon, String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstAidTab extends StatelessWidget {
  const _FirstAidTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAidCard(context, 'Minor Burns', 'Cool the burn under cool running water for 10-15 minutes. Do not apply ice or grease.'),
        _buildAidCard(context, 'Bleeding/Cuts', 'Apply direct pressure with a clean cloth. Elevate the injured area if possible.'),
        _buildAidCard(context, 'Fractures', 'Immobilize the area. Do not try to realign the bone. Call for emergency medical help.'),
        _buildAidCard(context, 'Heatstroke', 'Move to a cool place, loosen clothes, and apply cool wet cloths. Sips of water if conscious. Call emergency!'),
        _buildAidCard(context, 'Smoke Inhalation', 'Get to fresh air immediately. Keep calm and seek medical help if breathing is difficult.'),
      ],
    );
  }

  Widget _buildAidCard(BuildContext context, String title, String action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(Icons.medical_services, size: 32, color: Theme.of(context).colorScheme.error),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(action),
        ),
      ),
    );
  }
}

class _DosAndDontsTab extends StatelessWidget {
  const _DosAndDontsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildColumn(context, 'DO\'S', Colors.green, [
                'Stay calm and positive.',
                'Follow official instructions.',
                'Keep emergency kits ready.',
                'Help children & elderly.',
                'Turn off main utilities when leaving.',
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildColumn(context, 'DON\'TS', Colors.red, [
                'Spread rumors or panic.',
                'Use elevators during fires/earthquakes.',
                'Drink potentially contaminated water.',
                'Return to dangerous areas before clearance.',
                'Leave candles unattended.',
              ]),
            )
          ],
        )
      ],
    );
  }

  Widget _buildColumn(BuildContext context, String title, MaterialColor color, List<String> items) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: color.shade900, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                title == 'DO\'S' ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        )),
      ],
    );
  }
}
