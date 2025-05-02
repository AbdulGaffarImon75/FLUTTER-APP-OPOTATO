import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class RestaurantDashboardPage extends StatefulWidget {
  const RestaurantDashboardPage({super.key});

  @override
  State<RestaurantDashboardPage> createState() =>
      _RestaurantDashboardPageState();
}

class _RestaurantDashboardPageState extends State<RestaurantDashboardPage> {
  final TextEditingController _offerNameController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _seatStatusController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? profileImageUrl;
  String? restaurantName;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          profileImageUrl = data['profile_image_url'];
          restaurantName = data['name'];
        });
      }
    }
  }

  Future<void> _postOffer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final offerData = {
        'name': _offerNameController.text,
        'price': '৳${_offerPriceController.text}',
        'imageURL': _imageUrlController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'posted_by': restaurantName ?? '',
        'profile_image_url': profileImageUrl ?? '',
      };

      await FirebaseFirestore.instance.collection('offers').add(offerData);

      _offerNameController.clear();
      _offerPriceController.clear();
      _seatStatusController.clear();
      _imageUrlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer posted successfully!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _offerNameController.dispose();
    _offerPriceController.dispose();
    _seatStatusController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : null,
                child:
                    (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 12),
            if (restaurantName != null)
              Center(
                child: Text(
                  restaurantName!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Post Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _offerNameController,
              decoration: const InputDecoration(
                labelText: 'Offer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _offerPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Post Seat Status (Optional)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seatStatusController,
              decoration: const InputDecoration(
                labelText: 'Seat Status (e.g. Available, Full)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _postOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Submit'),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
    );
  }
}
