// views/pages/restaurant_view_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant_model.dart';
import '../../models/offer_model.dart';
import '../../models/combo_model.dart';
import 'bottom_nav_bar.dart';
import 'menu_page.dart';
import 'review_page.dart';

class RestaurantViewPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantViewPage({super.key, required this.restaurantId});

  @override
  State<RestaurantViewPage> createState() => _RestaurantViewPageState();
}

class _RestaurantViewPageState extends State<RestaurantViewPage> {
  final RestaurantController _ctrl = RestaurantController();

  RestaurantModel? _restaurant;
  List<OfferModel> _offers = [];
  List<ComboModel> _combos = [];

  bool _isCustomer = false;
  bool _isFollowing = false;
  bool _isCheckedIn = false;
  String _customerName = '';

  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    // 1. Load restaurant info
    _restaurant = await _ctrl.fetchRestaurant(widget.restaurantId);

    // 2. If logged in, check customer status & name
    if (_userId != null) {
      _isCustomer = await _ctrl.isCustomer(_userId!);
      if (_isCustomer) {
        _customerName = await _ctrl.fetchUserName(_userId!);
        _isFollowing = await _ctrl.fetchFollowStatus(
          _userId!,
          widget.restaurantId,
        );
        _isCheckedIn = await _ctrl.fetchCheckInStatus(
          _userId!,
          widget.restaurantId,
        );
      }
    }

    // 3. Load offers & combos
    if (_restaurant != null) {
      _offers = await _ctrl.fetchOffers(widget.restaurantId);
      _combos = await _ctrl.fetchCombos(_restaurant!.name);
    }

    setState(() => _loading = false);
  }

  Future<void> _handleFollow() async {
    if (!_isCustomer || _userId == null || _restaurant == null) return;
    await _ctrl.toggleFollow(
      userId: _userId!,
      restaurantId: widget.restaurantId,
      restaurantName: _restaurant!.name,
      customerName: _customerName,
      currentlyFollowing: _isFollowing,
    );
    setState(() => _isFollowing = !_isFollowing);
  }

  Future<void> _handleCheckIn() async {
    if (!_isCustomer || _userId == null || _restaurant == null) return;
    await _ctrl.toggleCheckIn(
      userId: _userId!,
      customerName: _customerName,
      restaurantId: widget.restaurantId,
      restaurantName: _restaurant!.name,
      currentlyCheckedIn: _isCheckedIn,
    );
    setState(() => _isCheckedIn = !_isCheckedIn);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _restaurant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final r = _restaurant!;
    return Scaffold(
      appBar: AppBar(
        title: Text(r.name),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: logo, name, check-in
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      r.imageUrl.isNotEmpty ? NetworkImage(r.imageUrl) : null,
                  child:
                      r.imageUrl.isEmpty
                          ? const Icon(Icons.store, size: 40)
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isCustomer)
                  ElevatedButton(
                    onPressed: _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCheckedIn
                              ? Colors.blue
                              : const Color.fromARGB(255, 230, 220, 250),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isCheckedIn ? 'Checked In' : 'Check In',
                      style: TextStyle(
                        color: _isCheckedIn ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),
            // action buttons
            Row(
              children: [
                _actionButton('Menu', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MenuPage(restaurantId: widget.restaurantId),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _actionButton('Reviews', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ReviewPage(restaurantId: widget.restaurantId),
                    ),
                  );
                }),
                if (_isCustomer) ...[
                  const SizedBox(width: 12),
                  _actionButton(
                    _isFollowing ? 'Unfollow' : 'Follow',
                    _handleFollow,
                    backgroundColor:
                        _isFollowing ? Colors.grey.shade300 : Colors.green,
                    textColor: _isFollowing ? Colors.black : Colors.white,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),
            // Offers
            const Text(
              'Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_offers.isEmpty)
              const Text('No offers yet.')
            else
              ..._offers.map(
                (o) => Card(
                  color: const Color.fromARGB(255, 245, 237, 255),
                  child: ListTile(
                    leading: Image.network(
                      o.imageUrl,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(o.title),
                    subtitle: Text(o.price),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            // Combos
            const Text(
              'Combos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_combos.isEmpty)
              const Text('No combos yet.')
            else
              ..._combos.map(
                (c) => Card(
                  color: const Color.fromARGB(255, 245, 237, 255),
                  child: ListTile(
                    leading: Image.network(
                      c.imageUrl,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(c.title),
                    subtitle: Text(c.price),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    VoidCallback onPressed, {
    Color backgroundColor = const Color.fromARGB(255, 230, 220, 250),
    Color textColor = Colors.black,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }
}
