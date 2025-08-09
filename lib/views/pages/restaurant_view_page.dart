// lib/views/pages/restaurant_view_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/restaurant_controller.dart';
import '../../controllers/cart_item_controller.dart';

import '../../models/restaurant_model.dart';
import '../../models/offer_model.dart';
import '../../models/combo_model.dart';

import 'bottom_nav_bar.dart';
import 'menu_page.dart';
import 'review_page.dart';
import 'package:O_potato/views/cart_page.dart';

class RestaurantViewPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantViewPage({super.key, required this.restaurantId});

  @override
  State<RestaurantViewPage> createState() => _RestaurantViewPageState();
}

// Variant option helper (outside the State class)
class _PriceOption {
  final String label; // e.g., "৳690"
  final int value; // e.g., 690
  const _PriceOption(this.label, this.value);
}

class _RestaurantViewPageState extends State<RestaurantViewPage> {
  final RestaurantController _ctrl = RestaurantController();
  final CartController _cart = CartController();

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

    // 1) Restaurant info
    _restaurant = await _ctrl.fetchRestaurant(widget.restaurantId);

    // 2) User status
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

    // 3) Offers & Combos
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

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Ensure cart contains only this restaurant's items (show replace dialog if not).
  Future<bool> _ensureSingleRestaurantCart() async {
    final hasOther = await _cart.hasItemsFromOtherRestaurants(
      widget.restaurantId,
    );
    if (!hasOther) return true;

    if (!mounted) return false;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Different restaurant in cart'),
            content: const Text(
              'Your cart contains items from another restaurant. '
              'Do you want to remove them and add this item instead?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Replace'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await _cart.clearForOtherRestaurants(widget.restaurantId);
      return true;
    }
    return false;
  }

  // ---------- variant picker helpers ----------

  List<_PriceOption> _extractPriceOptions(String priceString) {
    final hasCurrency = priceString.contains('৳') || priceString.contains('Tk');
    final matches = RegExp(r'\d+').allMatches(priceString).toList();
    if (matches.isEmpty) {
      return [_PriceOption(priceString, 0)];
    }
    return matches.map((m) {
      final n = int.tryParse(m.group(0)!) ?? 0;
      final label = hasCurrency ? '৳$n' : n.toString();
      return _PriceOption(label, n);
    }).toList();
  }

  Future<_PriceOption?> _pickVariant({
    required String priceString,
    required String titleForSheet,
  }) async {
    final options = _extractPriceOptions(priceString);

    if (options.length == 1) return options.first;

    if (!mounted) return null;
    return showModalBottomSheet<_PriceOption>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Choose a price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      titleForSheet,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              ...options.map(
                (opt) => ListTile(
                  title: Text(opt.label),
                  onTap: () => Navigator.pop(ctx, opt),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addOffer(OfferModel o, RestaurantModel r) async {
    if (!_isCustomer) return;
    if (!await _ensureSingleRestaurantCart()) return;

    final picked = await _pickVariant(
      priceString: o.price,
      titleForSheet: o.title,
    );
    if (picked == null) return;

    await _cart.addItem(
      type: 'offer',
      restaurantId: widget.restaurantId,
      restaurantName: r.name,
      title: o.title,
      imageUrl: o.imageUrl,
      priceLabel: picked.label,
      priceValue: picked.value,
      sourceId: '', // pass OfferModel id if you have one
    );
    _toast('Added to cart');
  }

  Future<void> _addCombo(ComboModel c, RestaurantModel r) async {
    if (!_isCustomer) return;
    if (!await _ensureSingleRestaurantCart()) return;

    final picked = await _pickVariant(
      priceString: c.price,
      titleForSheet: c.title,
    );
    if (picked == null) return;

    await _cart.addItem(
      type: 'combo',
      restaurantId: widget.restaurantId,
      restaurantName: r.name,
      title: c.title,
      imageUrl: c.imageUrl,
      priceLabel: picked.label,
      priceValue: picked.value,
      sourceId: '', // pass ComboModel id if you have one
    );
    _toast('Added to cart');
  }

  // ---------- build ----------

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
        actions: [
          if (_isCustomer) // Only show cart for customers
            StreamBuilder<int>(
              stream: _cart.cartCountStream(),
              builder: (context, snap) {
                final count = snap.data ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Open Cart',
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo, name, check-in
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

            // Action buttons
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

            // Offers (with Add to Cart)
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
                    trailing:
                        _isCustomer
                            ? IconButton(
                              tooltip: 'Add to Cart',
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                try {
                                  await _addOffer(o, r);
                                } catch (e) {
                                  _toast('Failed to add: $e');
                                }
                              },
                            )
                            : null,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Combos (with Add to Cart)
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
                    trailing:
                        _isCustomer
                            ? IconButton(
                              tooltip: 'Add to Cart',
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                try {
                                  await _addCombo(c, r);
                                } catch (e) {
                                  _toast('Failed to add: $e');
                                }
                              },
                            )
                            : null,
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
