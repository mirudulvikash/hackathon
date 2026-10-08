import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data/disaster_data.dart';
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

  final List<String> _filters = [
    'All',
    'Natural Disasters',
    'Man-Made Disasters',
    'Recommended for Your Area'
  ];

  List<DisasterModel> _getFilteredDisasters(String userLocation) {
    return mockDisasters.where((disaster) {
      final matchesSearch = disaster.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFilter = true;
      if (_selectedFilter == 'Natural Disasters') {
        matchesFilter = disaster.category == 'Natural';
      } else if (_selectedFilter == 'Man-Made Disasters') {
        matchesFilter = disaster.category == 'Man-Made';
      } else if (_selectedFilter == 'Recommended for Your Area') {
        matchesFilter = disaster.relevantLocations.contains(userLocation);
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().profile;
    final userLocation = userProfile?.location ?? '';

    final filteredList = _getFilteredDisasters(userLocation);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a disaster...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilter = filter;
                        } else {
                          // Prevent unselecting all (keep 'All' selected fallback)
                          _selectedFilter = 'All';
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // List of Disasters
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('No disasters found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final disaster = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisasterDetailScreen(
                                  disaster: disaster,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    disaster.iconName,
                                    size: 32,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              disaster.name,
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: disaster.category == 'Natural' 
                                                  ? Colors.green.withValues(alpha: 0.2) 
                                                  : Colors.orange.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              disaster.category,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: disaster.category == 'Natural' 
                                                    ? Colors.green[800] 
                                                    : Colors.orange[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        disaster.shortDescription,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
