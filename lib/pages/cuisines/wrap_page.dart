import 'package:flutter/material.dart';

class WrapsPage extends StatelessWidget {
  const WrapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wraps'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/wraps.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wrap Restaurants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRestaurantCard(
              'Wrap Studio',
              'Middle Eastern, Fast Food',
              '4.4',
              '20-35 min',
              'assets/wrap_studio.jpg',
            ),
            _buildRestaurantCard(
              'Shawarma House',
              'Middle Eastern',
              '4.2',
              '15-30 min',
              'assets/shawarma_house.jpg',
            ),
            _buildRestaurantCard(
              'Wrap & Roll',
              'Fusion Wraps',
              '4.0',
              '25-40 min',
              'assets/wrap_roll.jpg',
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
