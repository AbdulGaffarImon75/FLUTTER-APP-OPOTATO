import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';

class Offer {
  final String title;
  final String price;
  final String imageUrl;

  Offer({required this.title, required this.price, required this.imageUrl});

  factory Offer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Offer(
      title: data['name'] ?? '',
      price: data['price'] ?? '',
      imageUrl: data['imageURL'] ?? '',
    );
  }
}

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Offer> _offers = [];
  Set<String> _bookmarkedTitles = {};
  bool _isCustomer = false;

  @override
  void initState() {
    super.initState();
    fetchOffers();
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

  Future<void> fetchOffers() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _offers = snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
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

  Future<void> _toggleBookmark(Offer offer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc('${offer.title}-offer');

    final isBookmarked = _bookmarkedTitles.contains(offer.title);

    if (isBookmarked) {
      await docRef.delete();
      setState(() => _bookmarkedTitles.remove(offer.title));
    } else {
      await docRef.set({
        'type': 'offer',
        'title': offer.title,
        'price': offer.price,
        'imageURL': offer.imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => _bookmarkedTitles.add(offer.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Offers'), centerTitle: true),
      body:
          _offers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children:
                      _offers.map((offer) => _buildOfferCard(offer)).toList(),
                ),
              ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              offer.imageUrl,
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
                      offer.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(offer.price, style: const TextStyle(fontSize: 12)),
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
                    _bookmarkedTitles.contains(offer.title)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: const Color.fromARGB(255, 127, 113, 233),
                  ),
                  onPressed: () => _toggleBookmark(offer),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
