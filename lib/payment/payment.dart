import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:O_potato/pages/profile_page.dart'; // Import ProfilePage
import 'bkash.dart'; // Import bkash.dart for navigation
import 'status.dart'; // Import status.dart

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? userType; // Initially null
  List<Map<String, dynamic>> restaurants = []; // For admin: list of restaurants
  Map<String, dynamic>? restaurantData; // For restaurant: payment status
  static const String adminUID =
      '9augevirHjVzo8izlXsJba568782'; // Match BottomNavBar
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    print('Starting _checkUserType'); // Debug log
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in, navigating to ProfilePage');
      setState(() {
        userType = 'guest';
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
      return;
    }

    if (user.uid == adminUID) {
      print('Admin user detected');
      setState(() {
        userType = 'admin';
      });
      // Navigate to status.dart instead of fetching data here
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatusPage()),
        );
      }
      return;
    }

    // Check if user is a restaurant
    print('Querying Firestore for user type');
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = userDoc.data();
    print('Firestore user data: $data'); // Debug log
    if (data != null && data['user_type'] == 'restaurant') {
      print('Restaurant user detected');
      setState(() {
        userType = 'restaurant';
      });
      await _fetchRestaurantData(user.uid);
    } else {
      print('User is not restaurant, navigating to ProfilePage');
      setState(() {
        userType = 'unauthorized';
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
    }
  }

  Future<void> _fetchAdminData() async {
    try {
      print('Fetching admin data from restaurants collection');
      final snapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();
      setState(() {
        restaurants =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
                'payment_status': data['payment_status'] ?? 'Unpaid', // Default
              };
            }).toList();
      });
      print('Admin data fetched, restaurants: ${restaurants.length}');
    } catch (e) {
      print('Error fetching admin data: $e');
      setState(() {
        restaurants = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading restaurant data')),
        );
      }
    }
  }

  Future<void> _fetchRestaurantData(String uid) async {
    try {
      print('Fetching restaurant data for UID: $uid');
      final doc =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(uid)
              .get();
      if (!doc.exists) {
        print('Restaurant document does not exist, creating new');
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final userData = userDoc.data();
        if (userData != null) {
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(uid)
              .set({
                'name': userData['name'] ?? 'Unknown Restaurant',
                'payment_status': 'Unpaid', // Default to Unpaid
                'available_seats': 0,
                'total_seats': 0,
                '2_people_seat': 12,
                '4_people_seat': 16,
                '8_people_seat': 24,
                '12_people_seat': 24,
              });
        }
      }
      final updatedDoc =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(uid)
              .get();
      setState(() {
        final data = updatedDoc.data();
        restaurantData =
            data != null
                ? {
                  ...data,
                  'payment_status':
                      data['payment_status'] ?? 'Unpaid', // Default
                }
                : {'payment_status': 'Unpaid'};
      });
      print('Restaurant data fetched: $restaurantData');
    } catch (e) {
      print('Error fetching restaurant data: $e');
      setState(() {
        restaurantData = {'payment_status': 'Error'};
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading payment status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (userType == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userType == 'admin') {
      // Admin view is now handled by status.dart
      return const SizedBox.shrink(); // Placeholder, navigation handled in _checkUserType
    } else if (userType == 'restaurant') {
      return _buildRestaurantView();
    } else {
      return const Center(child: Text('No access to payment details'));
    }
  }

  Widget _buildRestaurantView() {
    if (restaurantData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final paymentStatus = restaurantData!['payment_status'] ?? 'Unpaid';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Payment Status: $paymentStatus',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (paymentStatus != 'Paid')
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      print('Pay with bKash button pressed'); // Debug log
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await onButtonTap('bkash', context: context);
                        // Refresh UI after returning from WebView
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await _fetchRestaurantData(user.uid);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Returned from bKash page. Please confirm payment status.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error during bKash navigation: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to open bKash page: $e. Please try again.',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: const Text('Pay with bKash'),
                  ),
          ],
        ),
      ),
    );
  }
}
