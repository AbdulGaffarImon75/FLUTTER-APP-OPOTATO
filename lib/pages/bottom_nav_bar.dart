import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;

  const BottomNavBar({super.key, this.activeIndex = 0});

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
              onPressed: () {},
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
