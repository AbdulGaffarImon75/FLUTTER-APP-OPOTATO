import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final followedSnapshot =
        await FirebaseFirestore.instance
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();

    final followedIds = followedSnapshot.docs.map((doc) => doc.id).toSet();

    final offersSnapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    final notifications =
        offersSnapshot.docs
            .where((doc) => followedIds.contains(doc['posted_by_id']))
            .map((doc) {
              final data = doc.data();
              return {
                'name': data['name'] ?? 'Unnamed Offer',
                'price': data['price'] ?? '',
                'imageURL': data['imageURL'] ?? '',
                'posted_by': data['posted_by'] ?? 'Unknown',
                'profile_image_url': data['profile_image_url'] ?? '',
                'timestamp': data['timestamp'],
              };
            })
            .toList();

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 3),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? const Center(child: Text('No new notifications'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            notification['profile_image_url'] != ''
                                ? NetworkImage(
                                  notification['profile_image_url'],
                                )
                                : null,
                        child:
                            notification['profile_image_url'] == ''
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(notification['name'] ?? ''),
                      subtitle: Text(
                        '${notification['posted_by']} · ${notification['price']}',
                      ),
                      trailing:
                          notification['imageURL'] != ''
                              ? Image.network(
                                notification['imageURL'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                  );
                },
              ),
    );
  }
}
