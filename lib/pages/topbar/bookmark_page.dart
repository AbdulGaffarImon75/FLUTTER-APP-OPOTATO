import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_nav_bar.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = [
      {
        'title': 'Family Feast Offer',
        'price': '৳1499',
        'restaurant': 'Khana’s',
        'image': 'assets/family_feast.jpg',
      },
      {
        'title': 'Chicken Burger Combo',
        'price': '৳499',
        'restaurant': 'Burger House',
        'image': 'assets/chicken_burger_combo.jpg',
      },
      {
        'title': 'Pizza Bonanza',
        'price': '৳999',
        'restaurant': 'Pizza Mania',
        'image': 'assets/pizza_bonanza.jpg',
      },
      {
        'title': 'Butter Naan Set',
        'price': '৳299',
        'restaurant': 'Meat & Marrow',
        'image': 'assets/butter_naan.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.bookmark, size: 80, color: Colors.purple),
                  SizedBox(height: 10),
                  Text(
                    'Bookmarks',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BookmarkDetailsPage(
                              title: bookmark['title']!,
                              restaurant: bookmark['restaurant']!,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookmark['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bookmark['price']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.purple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bookmark['restaurant']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: Colors.grey[300],
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                bookmark['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarkDetailsPage extends StatelessWidget {
  final String title;
  final String restaurant;

  const BookmarkDetailsPage({
    super.key,
    required this.title,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Text(
          'Details for "$title"\nfrom "$restaurant"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
