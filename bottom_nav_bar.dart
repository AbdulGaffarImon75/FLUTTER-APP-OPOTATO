import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;

  const BottomNavBar({super.key, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home_filled, size: 28),
              color: activeIndex == 0 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, size: 28),
              color: activeIndex == 1 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home_filled, size: 28),
              color: activeIndex == 2 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart, size: 28),
              color: activeIndex == 3 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person, size: 28),
              color: activeIndex == 4 ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
