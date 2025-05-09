import 'package:flutter/material.dart';

class KacchiPage extends StatelessWidget {
  const KacchiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Kacchi'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/kacchi.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kacchi Restaurants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRestaurantCard(
              'Kacchi Bhai',
              'Traditional Kacchi Biryani',
              '4.5',
              '30-45 min',
              'assets/kacchi_bhai.jpg',
            ),
            _buildRestaurantCard(
              'Sultan\'s Dine',
              'Premium Kacchi',
              '4.7',
              '40-55 min',
              'assets/sultans_dine.jpg',
            ),
            _buildRestaurantCard(
              'Kacchi Ghar',
              'Homestyle Kacchi',
              '4.3',
              '25-40 min',
              'assets/kacchi_ghar.jpg',
            ),
            _buildRestaurantCard(
              'Biryani House',
              'Kacchi & Morog Polao',
              '4.2',
              '35-50 min',
              'assets/biryani_house.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String name,
    String specialty,
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
                    specialty,
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
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // Navigation to restaurant detail page would go here
              },
            ),
          ],
        ),
      ),
    );
  }
}
