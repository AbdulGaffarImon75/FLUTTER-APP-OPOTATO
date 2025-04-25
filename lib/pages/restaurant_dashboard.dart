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

  Future<bool> _checkIfLoggedIn() async {
    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    return user != null; // If user is logged in, return true
  }

  Future<void> _postOffer() async {
    // Get logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to Firestore
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('users');

      // Update or add restaurant offer and seat status data under the user's document
      await usersCollection.doc(user.uid).set({
        'offer_name': _offerNameController.text,
        'offer_price': _offerPriceController.text,
        'seat_status': _seatStatusController.text,
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp for record
      }, SetOptions(merge: true)); // merge to avoid overwriting existing data

      // Clear inputs after posting offer
      _offerNameController.clear();
      _offerPriceController.clear();
      _seatStatusController.clear();

      // Provide user feedback
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
              backgroundColor: Colors.deepOrangeAccent,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postOffer, // Call the post offer function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
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
                      onPressed:
                          _postOffer, // Same function to update seat status
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
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
