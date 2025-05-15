import 'package:flutter/material.dart';

class BurgerPage extends StatelessWidget {
  const BurgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Burgers'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/burger.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Burger Joints',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRestaurantCard(
              'Burger King',
              'American, Fast Food',
              '4.3',
              '20-35 min',
              'assets/burger_king.jpg',
            ),
            _buildRestaurantCard(
              'McDonald\'s',
              'American, Fast Food',
              '4.1',
              '15-30 min',
              'assets/mcdonalds.jpg',
            ),
            _buildRestaurantCard(
              'Burger Lab',
              'Gourmet Burgers',
              '4.5',
              '25-40 min',
              'assets/burger_lab.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String name,
    String cuisine,
    String rating,
    String deliveryTime,
    String image,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    cuisine,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      Text(deliveryTime),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
