import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'restaurant_dashboard.dart';
import 'seat_booking.dart';
import 'chatbot_page.dart'; // ✅ ChatBot screen

class BottomNavBar extends StatelessWidget {
  final int activeIndex;

  const BottomNavBar({super.key, this.activeIndex = 0});

  // Check if user is logged in
  Future<bool> _isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
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
            // 🍔 Restaurant Dashboard
            IconButton(
              onPressed: () async {
                bool loggedIn = await _isUserLoggedIn();
                if (loggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantDashboardPage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.fastfood),
              color: activeIndex == 0 ? Colors.purple : Colors.grey,
            ),

            // 🎟️ Seat Booking
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeatBookingPage()),
                );
              },
              icon: const Icon(Icons.event_seat),
              color: activeIndex == 1 ? Colors.purple : Colors.grey,
            ),

            // 🏠 Home
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              icon: const Icon(Icons.home_filled),
              color: activeIndex == 2 ? Colors.purple : Colors.grey,
            ),

            // 💬 AI Chatbot
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatbotPage()),
                );
              },
              icon: const Icon(Icons.chat),
              color: activeIndex == 3 ? Colors.purple : Colors.grey,
            ),

            // 👤 Profile
            IconButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
