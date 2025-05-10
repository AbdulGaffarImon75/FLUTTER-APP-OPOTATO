import 'package:flutter/material.dart';

class SearchResultsWidget extends StatelessWidget {
  final String query;
  final List<Map<String, dynamic>> offers;
  final List<Map<String, dynamic>> restaurants;
  final List<Map<String, dynamic>> combos;
  final List<Map<String, dynamic>> cuisines;

  const SearchResultsWidget({
    super.key,
    required this.query,
    required this.offers,
    required this.restaurants,
    required this.combos,
    required this.cuisines,
  });

  List<Map<String, dynamic>> get _filteredSearchResults {
    final lowerQuery = query.toLowerCase();

    final filteredRestaurants =
        restaurants
            .where((rest) => rest['name'].toLowerCase().contains(lowerQuery))
            .map((rest) => {...rest, 'type': 'restaurant'})
            .toList();

    final filteredCuisines =
        cuisines
            .where((c) => c['label'].toLowerCase().contains(lowerQuery))
            .map(
              (c) => {
                'name': c['label'],
                'imageURL': c['imageUrl'],
                'type': 'cuisine',
              },
            )
            .toList();

    final filteredOffers =
        offers
            .where((offer) => offer['name'].toLowerCase().contains(lowerQuery))
            .map((offer) => {...offer, 'type': 'offer'})
            .toList();

    final filteredCombos =
        combos
            .where(
              (combo) => combo['title'].toLowerCase().contains(lowerQuery),
              //combo['vendor'].toLowerCase().contains(lowerQuery),
            )
            .map((combo) => {...combo, 'type': 'combo'})
            .toList();

    return [
      ...filteredRestaurants,
      ...filteredCuisines,
      ...filteredOffers,
      ...filteredCombos,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredSearchResults;
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text("No matching results found."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          results.map((result) {
            return ListTile(
              leading: Image.network(
                result['imageURL'] ?? result['image'] ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.image),
              ),
              title: Text(result['name'] ?? result['title'] ?? 'Unknown'),
              subtitle: Text(
                result['type'],
                style: TextStyle(
                  color:
                      result['type'] == 'restaurant'
                          ? Colors.orange
                          : result['type'] == 'cuisine'
                          ? Colors.green
                          : result['type'] == 'offer'
                          ? Colors.blue
                          : Colors.purple,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            DummyPage(result['name'] ?? result['title'] ?? ''),
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Text(
          'Welcome to $title Page!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
