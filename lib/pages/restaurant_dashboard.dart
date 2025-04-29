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

  Future<bool> _checkIfLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<void> _postOffer() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('users');

      await usersCollection.doc(user.uid).set({
        'offer_name': _offerNameController.text,
        'offer_price': _offerPriceController.text,
        'seat_status': _seatStatusController.text,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('offers').add({
        'name': _offerNameController.text,
        'price': '৳${_offerPriceController.text}',
        'imageURL': _imageUrlController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _offerNameController.clear();
      _offerPriceController.clear();
      _seatStatusController.clear();
      _imageUrlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer and Seat Status Updated!')),
      );
    }
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
    return FutureBuilder<bool>(
      future: _checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
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
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images.jpg'),
                    ),
                  ),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Post Offer'),
                    ),
                  ),
                  const Divider(height: 40, thickness: 1.5),
                  const Text(
                    'Update Seat Status',
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Update Seat Status'),
                    ),
                  ),
                  const SizedBox(height: 290),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BottomNavBar(activeIndex: 0),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('You must be logged in to access this page.'),
            ),
          );
        }
      },
    );
  }
}
