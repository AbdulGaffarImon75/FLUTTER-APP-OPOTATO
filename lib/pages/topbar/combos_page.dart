import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';

class Combo {
  final String title;
  final String vendor;
  final String price;
  final String imageUrl;

  Combo({
    required this.title,
    required this.vendor,
    required this.price,
    required this.imageUrl,
  });

  factory Combo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Combo(
      title: data['title'] ?? '',
      vendor: data['vendor'] ?? '',
      price: '৳${data['price'].toString()}',
      imageUrl: data['imageURL'] ?? '',
    );
  }
}

class CombosPage extends StatefulWidget {
  const CombosPage({super.key});

  @override
  State<CombosPage> createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  List<Combo> _combos = [];
  Set<String> _bookmarkedTitles = {};
  bool _isCustomer = false;

  @override
  void initState() {
    super.initState();
    fetchCombos();
    fetchBookmarks();
    checkIfCustomer();
  }

  Future<void> checkIfCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    final type = doc.data()?['user_type'];
    setState(() => _isCustomer = (type == 'customer'));
  }

  Future<void> fetchCombos() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _combos = snapshot.docs.map((doc) => Combo.fromFirestore(doc)).toList();
    });
  }

  Future<void> fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .get();

    setState(() {
      _bookmarkedTitles =
          snapshot.docs
              .map((doc) => (doc.data()['title'] ?? '') as String)
              .toSet();
    });
  }

  Future<void> _toggleBookmark(Combo combo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${combo.title}-combo');

    final isBookmarked = _bookmarkedTitles.contains(combo.title);

    if (isBookmarked) {
      await docRef.delete();
      setState(() => _bookmarkedTitles.remove(combo.title));
    } else {
      await docRef.set({
        'type': 'combo',
        'title': combo.title,
        'vendor': combo.vendor,
        'price': combo.price,
        'imageURL': combo.imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => _bookmarkedTitles.add(combo.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Combos'), centerTitle: true),
      body:
          _combos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children:
                      _combos.map((combo) => _buildComboCard(combo)).toList(),
                ),
              ),
    );
  }

  Widget _buildComboCard(Combo combo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              combo.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                color: Colors.white70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${combo.vendor} · ${combo.price}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (_isCustomer)
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  icon: Icon(
                    _bookmarkedTitles.contains(combo.title)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: const Color.fromARGB(255, 127, 113, 233),
                  ),
                  onPressed: () => _toggleBookmark(combo),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
