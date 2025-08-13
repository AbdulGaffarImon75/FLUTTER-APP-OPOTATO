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

// Variant option helper (outside the State class)
class _PriceOption {
  final String label; // e.g., "৳690"
  final int value; // e.g., 690
  const _PriceOption(this.label, this.value);
}

class RestaurantViewPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantViewPage({super.key, required this.restaurantId});

  @override
  State<RestaurantViewPage> createState() => _RestaurantViewPageState();
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
  String? _error;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;

      // 1) Restaurant info (required to proceed)
      final r = await _ctrl.fetchRestaurant(widget.restaurantId);
      if (!mounted) return;
      if (r == null) {
        setState(() {
          _restaurant = null;
          _loading = false;
          _error = 'Restaurant not found';
        });
        return;
      }
      _restaurant = r;

      // 2) User status (in parallel where possible)
      if (_userId != null) {
        final isCust = await _ctrl.isCustomer(_userId!);
        if (!mounted) return;
        _isCustomer = isCust;

        if (isCust) {
          final results = await Future.wait([
            _ctrl.fetchUserName(_userId!),
            _ctrl.fetchFollowStatus(_userId!, widget.restaurantId),
            _ctrl.fetchCheckInStatus(_userId!, widget.restaurantId),
          ]);
          if (!mounted) return;
          _customerName = results[0] as String;
          _isFollowing = results[1] as bool;
          _isCheckedIn = results[2] as bool;
        }
      }

      // 3) Offers & Combos (now that we know restaurant)
      try {
        _offers = await _ctrl.fetchOffers(widget.restaurantId);
      } catch (e) {
        // Keep page usable even if offers query fails
        debugPrint('fetchOffers failed: $e');
        _offers = const [];
      }

      try {
        _combos = await _ctrl.fetchCombos(_restaurant!.name);
      } catch (e) {
        debugPrint('fetchCombos failed: $e');
        _combos = const [];
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e, st) {
      debugPrint('Restaurant init failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleFollow() async {
    if (!_isCustomer || _userId == null || _restaurant == null) return;
    try {
      await _ctrl.toggleFollow(
        userId: _userId!,
        restaurantId: widget.restaurantId,
        restaurantName: _restaurant!.name,
        customerName: _customerName,
        currentlyFollowing: _isFollowing,
      );
      if (!mounted) return;
      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      _toast('Failed to update follow: $e');
    }
  }

  Future<void> _handleCheckIn() async {
    if (!_isCustomer || _userId == null || _restaurant == null) return;
    try {
      await _ctrl.toggleCheckIn(
        userId: _userId!,
        customerName: _customerName,
        restaurantId: widget.restaurantId,
        restaurantName: _restaurant!.name,
        currentlyCheckedIn: _isCheckedIn,
      );
      if (!mounted) return;
      setState(() => _isCheckedIn = !_isCheckedIn);
    } catch (e) {
      _toast('Failed to update check-in: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    // (Snackbar is safe inside our global phone box)
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
              ElevatedButton(
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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BottomNavBar(activeIndex: 2),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load restaurant.\n$_error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _initAll, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      );
    }

    if (_restaurant == null) {
      return const Scaffold(
        body: Center(child: Text('Restaurant not found')),
        bottomNavigationBar: BottomNavBar(activeIndex: 2),
      );
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
                // CircleAvatar has no errorBuilder; use ClipOval + Image.network
                ClipOval(
                  child: Image.network(
                    r.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const SizedBox(
                          width: 80,
                          height: 80,
                          child: Icon(Icons.store, size: 40),
                        ),
                  ),
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
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        o.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.image_not_supported),
                            ),
                      ),
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
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        c.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.image_not_supported),
                            ),
                      ),
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
