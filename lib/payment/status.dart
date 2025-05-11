import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Map<String, dynamic>> restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _fetchRestaurantData() async {
    try {
      print('Fetching restaurant data for admin status');
      final snapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();
      setState(() {
        restaurants =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['name'] ?? 'Unknown Restaurant',
                'payment_status': data['payment_status'] ?? 'Unpaid',
              };
            }).toList();
        _isLoading = false;
      });
      print('Restaurant data fetched, restaurants: ${restaurants.length}');
    } catch (e) {
      print('Error fetching restaurant data: $e');
      setState(() {
        restaurants = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading restaurant statuses')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Payment Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : restaurants.isEmpty
              ? const Center(child: Text('No restaurants found'))
              : ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return ListTile(
                    title: Text(restaurant['name']),
                    subtitle: Text(
                      'Payment Status: ${restaurant['payment_status']}',
                    ),
                  );
                },
              ),
    );
  }
}
