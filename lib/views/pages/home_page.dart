// views/pages/home_page.dart

import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../models/cuisine_model.dart';
import '../../models/combo_model.dart';
import '../../models/offer_model.dart';
import '../../models/restaurant_model.dart';
import '../../models/billboard_model.dart';
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
import 'advertisement_popup.dart';
import 'search_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _ctrl = HomeController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  List<CuisineModel> _cuisines = [];
  List<ComboModel> _combos = [];
  List<OfferModel> _offers = [];
  List<RestaurantModel> _restaurants = [];
  BillboardModel? _billboard;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
  }

  Future<void> _loadAll() async {
    final c = await _ctrl.fetchCuisines();
    final co = await _ctrl.fetchCombos();
    final o = await _ctrl.fetchOffers();
    final r = await _ctrl.fetchRestaurants();
    final b = await _ctrl.fetchLatestBillboard();
    setState(() {
      _cuisines = c;
      _combos = co;
      _offers = o;
      _restaurants = r;
      _billboard = b;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    if (_query.isNotEmpty)
                      SearchResultsPage(
                        query: _query,
                        offers: _offers,
                        restaurants: _restaurants,
                        combos: _combos,
                        cuisines: _cuisines,
                      )
                    else ...[
                      _actionButtons(),
                      const SizedBox(height: 16),
                      if (_billboard != null) _billboardCard(),
                      const SizedBox(height: 20),
                      _cuisineSection(),
                      const SizedBox(height: 20),
                      _comboSection(),
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Image.asset('assets/logo.png', width: 40, height: 40),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
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
    );
  }

  Widget _actionButtons() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _btn(Icons.star, 'Rewards', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RewardsPage()),
          );
        }),
        _btn(Icons.local_offer, 'Offers', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OffersPage()),
          );
        }),
        _btn(Icons.restaurant, 'Restaurants', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FollowingPage()),
          );
        }),
        _btn(Icons.shopping_bag, 'Combos', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CombosPage()),
          );
        }),
        _btn(Icons.location_on_rounded, 'Check Ins', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckInPage()),
          );
        }),
      ],
    ),
  );

  Widget _billboardCard() => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Stack(
      children: [
        Image.network(
          _billboard!.imageUrl,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.all(6),
            color: Colors.white70,
            child: Text(
              _billboard!.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _cuisineSection() {
    if (_cuisines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuisines',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cuisines.length,
            itemBuilder: (_, i) => _cuisineCard(_cuisines[i]),
          ),
        ),
      ],
    );
  }

  Widget _cuisineCard(CuisineModel c) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Column(
      children: [
        ClipOval(
          child: Image.network(
            c.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(c.label),
      ],
    ),
  );

  Widget _comboSection() {
    if (_combos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Combo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _combos.length,
            itemBuilder: (_, i) => _comboCard(_combos[i]),
          ),
        ),
      ],
    );
  }

  Widget _comboCard(ComboModel c) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            c.imageUrl,
            height: 120,
            width: 160,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.vendor,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                c.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.price,
                style: const TextStyle(fontSize: 14, color: Colors.purple),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _btn(IconData icon, String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 12),
      ),
    ),
  );
}
