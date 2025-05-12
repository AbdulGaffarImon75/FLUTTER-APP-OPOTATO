import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class RestaurantNotificationPage extends StatefulWidget {
  const RestaurantNotificationPage({super.key});

  @override
  State<RestaurantNotificationPage> createState() =>
      _RestaurantNotificationPageState();
}

class _RestaurantNotificationPageState
    extends State<RestaurantNotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(user.uid)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

    final notifications =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'message': data['message'] ?? '',
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          };
        }).toList();

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      bottomNavigationBar: const BottomNavBar(activeIndex: 3),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(notification['message']),
                      subtitle: Text(
                        notification['timestamp'] != null
                            ? notification['timestamp'].toString()
                            : 'Time unknown',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
