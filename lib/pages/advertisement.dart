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
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: MediaQuery.of(context).size.height * 0.455,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$title - $price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Offered by $poster',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // setState(() => _visible = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          126,
                          84,
                          243,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Order Now",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "T&Cs apply.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (_showClose)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() => _visible = false);
                      _currentAdIndex++;
                      Future.delayed(const Duration(seconds: 120), () {
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
      ),
    );
  }
}
