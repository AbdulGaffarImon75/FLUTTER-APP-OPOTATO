import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_nav_bar.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final List<Map<String, dynamic>> restaurants = [
    {
      'name': 'KFC',
      'logo': 'assets/kfc_logo.png',
      'isFollowing': true,
      'isFavorite': false,
    },
    {
      'name': 'Pizzaburg',
      'logo': 'assets/pizzaburg_logo.png',
      'isFollowing': true,
      'isFavorite': true,
    },
    {
      'name': 'Kacchi Bhai',
      'logo': 'assets/kacchi_bhai_logo.png',
      'isFollowing': true,
      'isFavorite': false,
    },
    {
      'name': 'Peyala Cafe',
      'logo': 'assets/peyala_cafe_logo.png',
      'isFollowing': true,
      'isFavorite': false,
    },
    {
      'name': 'Meat & Marrow',
      'logo': 'assets/meat_marrow_logo.png',
      'isFollowing': true,
      'isFavorite': true,
    },
    {
      'name': 'Domino\'s Pizza',
      'logo': 'assets/dominos_logo.png',
      'isFollowing': true,
      'isFavorite': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Following'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DummyRestaurantPage(restaurant['name']),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      restaurant['logo'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 30),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      restaurant['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            restaurant['isFollowing'] =
                                !restaurant['isFollowing'];
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              restaurant['isFollowing']
                                  ? Colors.grey.shade300
                                  : Colors.green,
                          minimumSize: const Size(80, 30),
                        ),
                        child: Text(
                          restaurant['isFollowing'] ? 'Unfollow' : 'Follow',
                          style: TextStyle(
                            color:
                                restaurant['isFollowing']
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            restaurant['isFavorite'] =
                                !restaurant['isFavorite'];
                          });
                        },
                        icon: Icon(
                          restaurant['isFavorite']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              restaurant['isFavorite']
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DummyRestaurantPage extends StatelessWidget {
  final String name;
  const DummyRestaurantPage(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name), centerTitle: true),
      body: Center(
        child: Text(
          'Profile page of $name\nComing soon!',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
