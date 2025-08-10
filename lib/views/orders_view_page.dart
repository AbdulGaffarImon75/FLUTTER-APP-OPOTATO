// lib/views/pages/orders_view_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/orders_controller.dart';
import '../../models/orders_model.dart';
import '../../views/pages/bottom_nav_bar.dart';
import '../../views/pages/restaurant_view_page.dart';

class OrdersViewPage extends StatefulWidget {
  const OrdersViewPage({super.key});

  @override
  State<OrdersViewPage> createState() => _OrdersViewPageState();
}

class _OrdersViewPageState extends State<OrdersViewPage> {
  final _ctrl = OrdersController();
  late Future<List<OrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ctrl.fetchMyOrders();
    _ensureCustomerOrExit();
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
          const SnackBar(content: Text('Only customers can access orders.')),
        );
      });
    }
  }

  Future<void> _reload() async {
    final f = _ctrl.fetchMyOrders();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body: FutureBuilder<List<OrderSummary>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            // Surface index/permission errors visibly
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load orders: ${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No orders found.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final o = items[i];
                final formatted = DateFormat(
                  'MMM d, yyyy – h:mm a',
                ).format(o.timestamp);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(order: o),
                        ),
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 237, 255),
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
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              o.restaurantImageUrl.isNotEmpty
                                  ? NetworkImage(o.restaurantImageUrl)
                                  : null,
                          child:
                              o.restaurantImageUrl.isEmpty
                                  ? const Icon(Icons.store, size: 30)
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.restaurantName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatted,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '৳${o.total}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailPage extends StatefulWidget {
  final OrderSummary order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _ctrl = OrdersController();
  late Future<List<OrderItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ctrl.fetchOrderItems(widget.order.id);
  }

  Future<void> _reload() async {
    final f = _ctrl.fetchOrderItems(widget.order.id);
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat(
      'MMM d, yyyy – h:mm a',
    ).format(widget.order.timestamp);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 4),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
        actions: [
          if (widget.order.restaurantId.isNotEmpty)
            IconButton(
              tooltip: 'View Restaurant',
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => RestaurantViewPage(
                          restaurantId: widget.order.restaurantId,
                        ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '৳${widget.order.total}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // Items
          Expanded(
            child: FutureBuilder<List<OrderItem>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load items: ${snap.error}'),
                    ),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text('No items found for this order.')),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 245, 237, 255),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  it.imageUrl.isNotEmpty
                                      ? NetworkImage(it.imageUrl)
                                      : null,
                              child:
                                  it.imageUrl.isEmpty
                                      ? const Icon(Icons.local_mall)
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    it.priceLabel,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Text('x${it.quantity}'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
