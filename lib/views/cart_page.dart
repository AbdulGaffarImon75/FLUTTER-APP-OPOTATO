// lib/views/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/cart_item_controller.dart';
import '../../controllers/orders_controller.dart'; // NEW
import '../../models/cart_item_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';
import 'package:O_potato/views/pages/bkash_payment_page.dart'; // NEW
import 'package:O_potato/views/orders_view_page.dart'; // NEW

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _ctrl = CartController();
  final _ordersCtrl = OrdersController(); // NEW
  late Future<List<CartItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ctrl.fetchCart();
    _ensureCustomerOrExit(); // customer-only guard
  }

  Future<void> _ensureCustomerOrExit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    bool isCustomer = false;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      isCustomer = doc.data()?['user_type'] == 'customer';
    }
    if (!mounted) return;
    if (!isCustomer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only customers can access the cart.')),
        );
      });
    }
  }

  /// Pull-to-refresh and internal reloads after edits.
  Future<void> _refresh() async {
    final fut = _ctrl.fetchCart();
    setState(() {
      _future = fut; // set synchronously; returns void
    });
    await fut; // let RefreshIndicator finish after data arrives
  }

  int _total(List<CartItem> items) =>
      items.fold(0, (sum, it) => sum + it.priceValue * it.quantity);

  // ===== Checkout alert (pattern matches RestaurantViewPage dialog style) =====
  Future<void> _onCheckout() async {
    final choice = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Choose payment method'),
            content: const Text('How would you like to pay?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'cod'),
                child: const Text('Cash on Delivery'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'bkash'),
                child: const Text('Pay with bKash'),
              ),
            ],
          ),
    );

    if (!mounted || choice == null) return;

    if (choice == 'bkash') {
      // Navigate to bKash flow (place the order there after successful payment)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BkashPaymentPage()),
      );
    } else if (choice == 'cod') {
      // Create order from current cart, clear cart, then show success + go to Orders
      final orderId = await _ordersCtrl.placeOrderFromCart();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderId == null
                ? 'Your cart is empty.'
                : 'Your order has been placed.',
          ),
        ),
      );

      if (orderId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrdersViewPage()),
        );
      }
    }
  }
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              await _ctrl.clearAll();
              await _refresh();
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: FutureBuilder<List<CartItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Your cart is empty.')),
                ],
              ),
            );
          }

          final total = _total(items);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...items.map(
                  (c) => _CartTile(
                    item: c,
                    onInc: () async {
                      await _ctrl.inc(c.id);
                      await _refresh();
                    },
                    onDec: () async {
                      await _ctrl.dec(c.id);
                      await _refresh();
                    },
                    onRemove: () async {
                      await _ctrl.remove(c.id);
                      await _refresh();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 237, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '৳$total',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _onCheckout, // <-- opens picker & handles flow
                  child: const Text('Proceed to Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  const _CartTile({
    required this.item,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('MMM d, yyyy – h:mm a').format(item.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 237, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
                item.imageUrl.isNotEmpty ? NetworkImage(item.imageUrl) : null,
            child:
                item.imageUrl.isEmpty
                    ? const Icon(Icons.local_mall, size: 28)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.restaurantName,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(item.priceLabel, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: onDec, icon: const Icon(Icons.remove)),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: onInc, icon: const Icon(Icons.add)),
            ],
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
