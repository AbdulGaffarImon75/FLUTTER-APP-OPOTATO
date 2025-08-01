import '../models/offer_model.dart';
import '../models/restaurant_model.dart';
import '../models/combo_model.dart';
import '../models/cuisine_model.dart';

/// Encapsulates your search‐filter logic.
class SearchPageController {
  /// Returns a unified list of maps, tagged by `"type"`, filtered by [query].
  List<Map<String, dynamic>> filterResults({
    required String query,
    required List<OfferModel> offers,
    required List<RestaurantModel> restaurants,
    required List<ComboModel> combos,
    required List<CuisineModel> cuisines,
  }) {
    final lower = query.toLowerCase();
    final List<Map<String, dynamic>> results = [];

    // Restaurants
    for (final r in restaurants) {
      if (r.name.toLowerCase().contains(lower)) {
        results.add({
          'name': r.name,
          'imageURL': r.imageUrl,
          'type': 'restaurant',
        });
      }
    }

    // Cuisines
    for (final c in cuisines) {
      if (c.label.toLowerCase().contains(lower)) {
        results.add({
          'name': c.label,
          'imageURL': c.imageUrl,
          'type': 'cuisine',
        });
      }
    }

    // Offers
    for (final o in offers) {
      if (o.title.toLowerCase().contains(lower)) {
        results.add({
          'name': o.title,
          'imageURL': o.imageUrl,
          'price': o.price,
          'type': 'offer',
        });
      }
    }

    // Combos
    for (final c in combos) {
      if (c.title.toLowerCase().contains(lower)) {
        results.add({
          'name': c.title,
          'imageURL': c.imageUrl,
          'price': c.price,
          'type': 'combo',
        });
      }
    }

    return results;
  }
}
