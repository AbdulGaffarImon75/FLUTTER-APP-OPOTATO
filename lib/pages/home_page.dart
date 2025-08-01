import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_nav_bar.dart';
import 'cuisines/kacchi_page.dart';
import 'cuisines/burger_page.dart';
import 'cuisines/wrap_page.dart';
import 'cuisines/pizza_page.dart';
import 'topbar/rewards_page.dart';
import 'topbar/offers_page.dart';
import 'topbar/following_page.dart';
import 'topbar/combos_page.dart';
import 'topbar/check_in_page.dart';
import 'advertisement.dart';
import 'search_results.dart';
import 'customer_map_page.dart';

class Cuisine {
  final String label;
  final String imageUrl;

  Cuisine({required this.label, required this.imageUrl});

  factory Cuisine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cuisine(
      label: data['label'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class Combo {
  final String title;
  final String vendor;
  final String price;
  final String image;

  Combo({
    required this.title,
    required this.vendor,
    required this.price,
    required this.image,
  });

  factory Combo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final price = data['price'] ?? '';
    return Combo(
      title: data['title'] ?? '',
      vendor: data['vendor'] ?? '',
      image: data['imageURL'] ?? '',
      price: price.toString().contains('৳') ? price : '৳$price',
    );
  }
}

class Billboard {
  final String imageUrl;
  final String title;

  Billboard({required this.imageUrl, required this.title});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Cuisine> _allCuisines = [];
  List<Combo> _combos = [];
  List<Map<String, dynamic>> _comboMaps = [];
  Billboard? _billboard;

  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    fetchCuisines();
    fetchCombos();
    fetchBillboard();
    fetchOffers();
    fetchRestaurants();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> fetchCuisines() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('cuisines').get();
    setState(() {
      _allCuisines =
          snapshot.docs.map((doc) => Cuisine.fromFirestore(doc)).toList();
    });
  }

  Future<void> fetchCombos() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();
    setState(() {
      _combos = snapshot.docs.map((doc) => Combo.fromFirestore(doc)).toList();
      _comboMaps =
          _combos
              .map(
                (c) => {
                  'title': c.title,
                  'vendor': c.vendor,
                  'image': c.image,
                  'price': c.price,
                },
              )
              .toList();
    });
  }

  Future<void> fetchBillboard() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>? ?? {};
      setState(() {
        _billboard = Billboard(
          imageUrl: data['imageURL'] ?? '',
          title: '${data['name'] ?? ''}\n${data['price'] ?? ''}',
        );
      });
    }
  }

  Future<void> fetchOffers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('offers').get();
    setState(() {
      _offers =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'] ?? '',
              'imageURL': data['imageURL'] ?? '',
              'price': data['price'] ?? '',
            };
          }).toList();
    });
  }

  Future<void> fetchRestaurants() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();

    setState(() {
      _restaurants =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'] ?? '',
              'imageURL': data['profile_image_url'] ?? '',
            };
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: const BottomNavBar(activeIndex: 2),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/logo.png', width: 40, height: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_searchQuery.isNotEmpty)
                      SearchResultsWidget(
                        query: _searchQuery,
                        offers: _offers,
                        restaurants: _restaurants,
                        combos: _comboMaps,
                        cuisines:
                            _allCuisines
                                .map(
                                  (c) => {
                                    'label': c.label,
                                    'imageUrl': c.imageUrl,
                                  },
                                )
                                .toList(),
                      )
                    else ...[
                      // Action Buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _actionButton(Icons.star, "Rewards", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RewardsPage(),
                                ),
                              );
                            }),
                            _actionButton(Icons.local_offer, "Offers", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OffersPage(),
                                ),
                              );
                            }),
                            _actionButton(Icons.restaurant, "Restaurants", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FollowingPage(),
                                ),
                              );
                            }),
                            _actionButton(Icons.map, "Maps", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerMapPage(),
                                ),
                              );
                            }),
                            _actionButton(Icons.shopping_bag, "Combos", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CombosPage(),
                                ),
                              );
                            }),
                            _actionButton(
                              Icons.location_on_rounded,
                              "Check Ins",
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckInPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Billboard
                      if (_billboard != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DummyPage(_billboard!.title),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _billboard!.imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Cuisines Section (NO arrow)
                      if (_allCuisines.isNotEmpty) ...[
                        const Text(
                          "Cuisines",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _allCuisines.length,
                            itemBuilder: (context, index) {
                              final cuisine = _allCuisines[index];
                              return GestureDetector(
                                onTap: () {
                                  final label = cuisine.label.toLowerCase();
                                  if (label == 'kacchi') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const KacchiPage(),
                                      ),
                                    );
                                  } else if (label == 'burger') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BurgerPage(),
                                      ),
                                    );
                                  } else if (label == 'pizza') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PizzaPage(),
                                      ),
                                    );
                                  } else if (label == 'wrap') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const WrapsPage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DummyPage(cuisine.label),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          cuisine.imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.fastfood,
                                                      size: 30,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(cuisine.label),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const Text(
                        "Explore Combo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _combos.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _combos.length,
                              itemBuilder: (context, index) {
                                final combo = _combos[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DummyPage(combo.title),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[100],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            combo.image,
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 120,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.image,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                combo.vendor,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                combo.title,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                combo.price,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.purple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const AdvertisementPopup(),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
