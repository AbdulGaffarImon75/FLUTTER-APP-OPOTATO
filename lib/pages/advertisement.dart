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
  Map<String, dynamic>? _advertisementItem;
  List<Map<String, dynamic>> _unfollowedItems = [];
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
    _unfollowedItems = await _fetchUnfollowedItems();
    if (_unfollowedItems.isNotEmpty) {
      _showPopup();
    }
  }

  void _showPopup() {
    setState(() {
      _advertisementItem =
          _unfollowedItems[_currentAdIndex % _unfollowedItems.length];
      _visible = true;
      _showClose = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showClose = true);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchUnfollowedItems() async {
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

    final combosSnapshot =
        await FirebaseFirestore.instance
            .collection('combos')
            .orderBy('timestamp', descending: true)
            .get();

    final offers =
        offersSnapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                ...data,
                'type': 'offer',
                'posterId': data['posted_by_id'],
                'poster': data['posted_by'] ?? 'Unknown',
                'title': data['name'],
              };
            })
            .where((item) => !followedIds.contains(item['posterId']))
            .toList();

    final combos =
        combosSnapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                ...data,
                'type': 'combo',
                'posterId': data['vendor_id'],
                'poster': data['vendor'] ?? 'Unknown',
                'title': data['title'],
              };
            })
            .where((item) => !followedIds.contains(item['posterId']))
            .toList();

    final combined = [...offers, ...combos];
    combined.sort(
      (a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp),
    );
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCustomer || !_visible || _advertisementItem == null) {
      return const SizedBox.shrink();
    }

    final imageUrl = _advertisementItem!['imageURL'] ?? '';
    final title = _advertisementItem!['title'] ?? 'Special Deal';
    final price = _advertisementItem!['price'] ?? '';
    final poster = _advertisementItem!['poster'] ?? 'Vendor';

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
                      onPressed: () {},
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
                        "Take a look",
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
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted && _unfollowedItems.isNotEmpty) {
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
