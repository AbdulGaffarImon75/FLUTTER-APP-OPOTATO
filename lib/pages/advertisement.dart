import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvertisementPopup extends StatefulWidget {
  const AdvertisementPopup({super.key});

  @override
  State<AdvertisementPopup> createState() => _AdvertisementPopupState();
}

class _AdvertisementPopupState extends State<AdvertisementPopup> {
  bool _visible = false;
  bool _showClose = false;
  Map<String, dynamic>? _advertisementOffer;
  List<Map<String, dynamic>> _unfollowedOffers = [];
  int _currentAdIndex = 0;
  bool _isCustomer = false;

  @override
  void initState() {
    super.initState();
    _checkIfCustomer();
  }

  Future<void> _checkIfCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userType = doc.data()?['user_type'];

    if (userType == 'customer') {
      setState(() => _isCustomer = true);
      _initializePopupCycle();
    }
  }

  void _initializePopupCycle() async {
    _unfollowedOffers = await _fetchUnfollowedOffers();
    if (_unfollowedOffers.isNotEmpty) {
      _showPopup();
    }
  }

  void _showPopup() {
    setState(() {
      _advertisementOffer =
          _unfollowedOffers[_currentAdIndex % _unfollowedOffers.length];
      _visible = true;
      _showClose = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showClose = true);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchUnfollowedOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final followedSnapshot =
        await FirebaseFirestore.instance
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();

    final followedIds = followedSnapshot.docs.map((doc) => doc.id).toSet();

    final offersSnapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    final unfollowed =
        offersSnapshot.docs.map((doc) => doc.data()).where((data) {
          final posterId = data['posted_by_id'];
          return posterId != null && !followedIds.contains(posterId);
        }).toList();

    return unfollowed;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCustomer || !_visible || _advertisementOffer == null) {
      return const SizedBox.shrink();
    }

    final imageUrl = _advertisementOffer!['imageURL'] ?? '';
    final title = _advertisementOffer!['name'] ?? 'Special Offer';
    final price = _advertisementOffer!['price'] ?? '';
    final poster = _advertisementOffer!['posted_by'] ?? '';

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$title - $price',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Offered by $poster',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (_showClose)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() => _visible = false);
                    _currentAdIndex++;
                    Future.delayed(const Duration(seconds: 30), () {
                      if (mounted && _unfollowedOffers.isNotEmpty) {
                        _showPopup();
                      }
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
