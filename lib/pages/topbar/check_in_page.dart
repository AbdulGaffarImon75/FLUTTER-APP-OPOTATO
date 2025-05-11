import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';
import 'package:O_potato/pages/restaurant_view_page.dart'; // adjust path as needed

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<Map<String, dynamic>> _checkIns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCheckIns();
  }

  Future<void> _fetchCheckIns() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('check-ins')
            .where('customer_id', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    final checkIns = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final restaurantId = data['restaurant_id'] as String?;
      final timestamp = data['timestamp'] as Timestamp?;
      if (restaurantId == null) continue; // skip bad docs

      // fetch restaurant profile
      final restDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(restaurantId)
              .get();
      final restData = restDoc.data();
      final imageUrl = restData?['profile_image_url'] as String? ?? '';
      final name = restData?['name'] as String? ?? 'Restaurant';

      checkIns.add({
        'restaurantId': restaurantId,
        'restaurant_name': name,
        'timestamp': timestamp,
        'image': imageUrl,
      });
    }

    if (!mounted) return;
    setState(() {
      _checkIns = checkIns;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(
        title: const Text('Check-Ins'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _checkIns.isEmpty
              ? const Center(child: Text("No check-ins found."))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _checkIns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final checkIn = _checkIns[index];
                  final rid = checkIn['restaurantId'] as String;
                  final name = checkIn['restaurant_name'] as String;
                  final image = checkIn['image'] as String;
                  final timestamp = checkIn['timestamp'] as Timestamp?;
                  final formattedTime =
                      timestamp != null
                          ? DateFormat(
                            'MMM d, yyyy – h:mm a',
                          ).format(timestamp.toDate())
                          : 'Unknown time';

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantViewPage(restaurantId: rid),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 237, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                image.isNotEmpty ? NetworkImage(image) : null,
                            child:
                                image.isEmpty
                                    ? const Icon(Icons.store, size: 30)
                                    : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
