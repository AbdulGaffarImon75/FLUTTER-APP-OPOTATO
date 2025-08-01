import 'package:flutter/material.dart';
import '../../controllers/search_controller.dart';
import '../../models/offer_model.dart';
import '../../models/restaurant_model.dart';
import '../../models/combo_model.dart';
import '../../models/cuisine_model.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  final List<OfferModel> offers;
  final List<RestaurantModel> restaurants;
  final List<ComboModel> combos;
  final List<CuisineModel> cuisines;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.offers,
    required this.restaurants,
    required this.combos,
    required this.cuisines,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SearchPageController();
    final results = controller.filterResults(
      query: query,
      offers: offers,
      restaurants: restaurants,
      combos: combos,
      cuisines: cuisines,
    );

    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text("No matching results found."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          results.map((item) {
            final type = item['type'] as String;
            final name = item['name'] as String;
            final imageUrl = item['imageURL'] as String? ?? '';

            return ListTile(
              leading: Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              ),
              title: Text(name),
              subtitle: Text(
                type,
                style: TextStyle(
                  color:
                      type == 'restaurant'
                          ? Colors.orange
                          : type == 'cuisine'
                          ? Colors.green
                          : type == 'offer'
                          ? Colors.blue
                          : Colors.purple,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DummyPage(name)),
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
