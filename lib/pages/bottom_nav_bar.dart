import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'restaurant_dashboard.dart';
import 'admin_dashboard.dart';
import 'seat_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatbot_page.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  static const String adminUID = '9augevirHjVzo8izlXsJba568782';

  const BottomNavBar({super.key, this.activeIndex = 0});

  Future<void> _handleFastFoodTapOptimized(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (user.uid == adminUID) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userType = doc.data()?['user_type'];

    if (userType == 'customer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    } else if (userType == 'restaurant') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RestaurantDashboardPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User type unknown or missing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _handleFastFoodTapOptimized(context),
              icon: const Icon(Icons.fastfood),
              color: activeIndex == 0 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeatBookingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.event_seat),
              color: activeIndex == 1 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: const Icon(Icons.home_filled),
              color: activeIndex == 2 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
              color: activeIndex == 3 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.person),
              color: activeIndex == 4 ? Colors.purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
