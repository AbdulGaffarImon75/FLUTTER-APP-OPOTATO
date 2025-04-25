import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'restaurant_dashboard.dart'; // Import the restaurant dashboard page

class BottomNavBar extends StatelessWidget {
  final int activeIndex;

  const BottomNavBar({super.key, this.activeIndex = 0});

  // Function to check if the user is logged in
  Future<bool> _isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user !=
        null; // Returns true if the user is logged in, false otherwise
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
              onPressed: () async {
                // Check if the user is logged in
                bool loggedIn = await _isUserLoggedIn();

                if (loggedIn) {
                  // If logged in, navigate to the restaurant dashboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestaurantDashboardPage(),
                    ),
                  );
                } else {
                  // Handle not logged-in state (you can show a login prompt or other UI)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.fastfood),
              color: activeIndex == 0 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
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
              icon: const Icon(Icons.shopping_cart),
              color: activeIndex == 3 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () async {
                // Check if the user is logged in
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // If logged in, navigate to the profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                } else {
                  // If not logged in, navigate to the login page
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
