import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;
  MenuPage({super.key, required this.restaurantId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _segmentController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? _vendorName;
  String? _userType;
  List<DocumentSnapshot> _menus = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get current user type
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
    _userType = userDoc.data()?['user_type'];

    // Get vendor (restaurant) name
    final vendorDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.restaurantId)
            .get();
    _vendorName = vendorDoc.data()?['name'];

    await _fetchMenus();
    setState(() {});
  }

  Future<void> _fetchMenus() async {
    if (_vendorName == null) return;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('menu')
            .where('vendor', isEqualTo: _vendorName)
            .orderBy('segment')
            .get();
    _menus = snapshot.docs;
  }

  Future<void> _postMenu() async {
    if (_vendorName == null) return;
    final menuData = {
      'title': _titleController.text,
      'segment': _segmentController.text,
      'price': '৳${_priceController.text}',
      'imageURL': _imageUrlController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'vendor': _vendorName,
    };
    await FirebaseFirestore.instance.collection('menu').add(menuData);
    _titleController.clear();
    _segmentController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    await _fetchMenus();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menu posted successfully!')));
  }

  Future<void> _deleteMenu(String docId) async {
    await FirebaseFirestore.instance.collection('menu').doc(docId).delete();
    await _fetchMenus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Group by segment
    final groupedMenus = <String, List<DocumentSnapshot>>{};
    for (var menu in _menus) {
      final segment = menu['segment'] ?? 'Other';
      groupedMenus.putIfAbsent(segment, () => []).add(menu);
    }
    final sortedSegments = groupedMenus.keys.toList()..sort();

    // Determine if current user is the restaurant owner of this page
    final isOwner =
        _userType == 'restaurant' &&
        FirebaseAuth.instance.currentUser?.uid == widget.restaurantId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_vendorName ?? 'Menu'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant owner can post new menu items
            if (isOwner) ...[
              const Text(
                'Post Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _segmentController,
                decoration: const InputDecoration(
                  hintText: 'Segment (e.g., Lunch, Drinks)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Price (e.g., ৳200)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _postMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text('POST MENU'),
              ),
              const SizedBox(height: 24),
            ],

            // Display each segment
            for (final segment in sortedSegments) ...[
              Text(
                segment,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...groupedMenus[segment]!.map((menu) {
                final data = menu.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading:
                        (data['imageURL'] ?? '').toString().isNotEmpty
                            ? Image.network(
                              data['imageURL'],
                              width: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.fastfood),
                    title: Text(data['title'] ?? ''),
                    subtitle: Text(data['price'] ?? ''),
                    // Only owner sees delete
                    trailing:
                        isOwner
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenu(menu.id),
                            )
                            : null,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
