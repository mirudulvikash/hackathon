import 'package:flutter/material.dart';

class EmergencyGuideScreen extends StatelessWidget {
  const EmergencyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Guide', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.errorContainer,
        foregroundColor: theme.colorScheme.onErrorContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Disclaimer Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  Icon(Icons.gavel, color: Colors.amber.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For educational & rapid guidance purposes. Always follow official instructions from emergency authorities.',
                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Emergency Helplines',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Helpline Strip
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildHelplineCard(context, '112', 'National Emergency', Icons.phone_in_talk, Colors.red),
                        const SizedBox(width: 12),
                        _buildHelplineCard(context, '108', 'Ambulance', Icons.local_hospital, Colors.green),
                        const SizedBox(width: 12),
                        _buildHelplineCard(context, '101', 'Fire Brigade', Icons.local_fire_department, Colors.orange),
                        const SizedBox(width: 12),
                        _buildHelplineCard(context, '1070 / 1077', 'Disaster Helpline', Icons.support_agent, Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Instant Action Protocol',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildActionCard(
                    context, 
                    'FLOOD WARNING', 
                    Icons.water, 
                    Colors.blue.shade700,
                    [
                      'Move to higher ground immediately.',
                      'Avoid walking or driving through moving water.',
                      'Switch off main electricity supplies if it is safe.',
                      'Follow official evacuation orders without delay.'
                    ],
                    'Strictly Avoid: Touching wet electrical appliances.',
                  ),
                  
                  _buildActionCard(
                    context, 
                    'FIRE BREAKOUT', 
                    Icons.local_fire_department, 
                    Colors.red.shade700,
                    [
                      'Raise the fire alarm instantly to alert everyone.',
                      'Evacuate immediately via the nearest safest exit.',
                      'Do NOT use lifts or elevators.',
                      'Stay low and crawl under thick smoke.'
                    ],
                    'Strictly Avoid: Hiding in closets or under desks.',
                  ),

                  _buildActionCard(
                    context, 
                    'EARTHQUAKE SEISMIC ACTIVITY', 
                    Icons.broken_image, 
                    Colors.brown.shade700,
                    [
                      'DROP downwards heavily to your hands and knees.',
                      'COVER your head and neck securely under a sturdy desk.',
                      'HOLD ON until the shaking completely stops.',
                      'Stay far away from glass, windows, and heavy fixtures.'
                    ],
                    'Strictly Avoid: Running outside while the building is shaking.',
                  ),

                  _buildActionCard(
                    context, 
                    'ELECTRICAL / LAB ACCIDENT', 
                    Icons.electric_bolt, 
                    Colors.deepPurple.shade700,
                    [
                      'Cut the main power/gas supply immediately.',
                      'Do not touch the victim with bare hands if they are shocked.',
                      'Use a dry completely wooden/plastic object to separate them.',
                      'Call campus security and apply correct first-aid.'
                    ],
                    'Strictly Avoid: Throwing water on an electrical or chemical fire.',
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineCard(BuildContext context, String number, String label, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(number, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, List<String> steps, String avoidText) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          
          // Steps
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: steps.asMap().entries.map((entry) {
                int index = entry.key;
                String stepText = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stepText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Disclaimer Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    avoidText,
                    style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
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
