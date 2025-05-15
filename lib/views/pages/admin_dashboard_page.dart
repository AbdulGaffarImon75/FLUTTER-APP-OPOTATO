import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../models/restaurant_admin_model.dart';
import '../../models/offer_model.dart';
import 'bottom_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _ctrl = AdminDashboardController();
  bool _loading = true;
  List<RestaurantAdminModel> _restaurants = [];
  List<OfferModel> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rests = await _ctrl.fetchRestaurants();
    final offs = await _ctrl.fetchOffers();
    if (!mounted) return;
    setState(() {
      _restaurants = rests;
      _offers = offs;
      _loading = false;
    });
  }

  Future<void> _confirmAndRemoveRestaurant(String uid) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Removal'),
            content: const Text(
              'Are you sure you want to remove this restaurant?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _ctrl.removeRestaurant(uid);
      await _loadData();
    }
  }

  Future<void> _removeOffer(String id) async {
    await _ctrl.removeOffer(id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Manage restaurants below:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    // Restaurants list
                    ..._restaurants
                        .map((r) => _buildRestaurantTile(r))
                        .toList(),
                    const SizedBox(height: 32),
                    const Text(
                      'All Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._offers.map((o) => _buildOfferTile(o)).toList(),
                  ],
                ),
              ),
    );
  }

  Widget _buildRestaurantTile(RestaurantAdminModel r) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                r.imageUrl.isNotEmpty ? NetworkImage(r.imageUrl) : null,
            child:
                r.imageUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              r.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => _confirmAndRemoveRestaurant(r.uid),
            style: TextButton.styleFrom(backgroundColor: Colors.red.shade100),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTile(OfferModel o) {
    final formatted =
        o.timestamp != null
            ? DateFormat('MMM d, h:mm a').format(o.timestamp!)
            : 'Unknown';
    return ListTile(
      title: Text(o.title),
      subtitle: Text('${o.postedBy} · $formatted'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _removeOffer(o.id),
      ),
    );
  }
}
