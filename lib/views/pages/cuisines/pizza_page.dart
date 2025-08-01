import 'package:flutter/material.dart';

class PizzaPage extends StatelessWidget {
  const PizzaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Pizza'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/pizza.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pizza Restaurants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRestaurantCard(
              'Domino\'s Pizza',
              'Italian, Fast Food',
              '4.2',
              '30-45 min',
              'assets/dominos.jpg',
            ),
            _buildRestaurantCard(
              'Pizza Hut',
              'Italian, American',
              '4.0',
              '25-40 min',
              'assets/pizza_hut.jpg',
            ),
            _buildRestaurantCard(
              'Italian Pizza',
              'Authentic Italian',
              '4.5',
              '35-50 min',
              'assets/italian_pizza.jpg',
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
