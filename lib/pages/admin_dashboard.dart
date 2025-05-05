import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bottom_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> _restaurants = [];
  List<DocumentSnapshot> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final restaurantSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();

    final restaurants =
        restaurantSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'name': data['name'] ?? 'Unnamed',
            'image': data['profile_image_url'] ?? '',
          };
        }).toList();

    final offersSnapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _restaurants = restaurants;
      _offers = offersSnapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _removeRestaurant(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Removal'),
            content: const Text(
              'Are you sure you want to remove this restaurant?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseFirestore.instance.collection('rest').doc(uid).delete();

    final offers =
        await FirebaseFirestore.instance
            .collection('offers')
            .where('posted_by_id', isEqualTo: uid)
            .get();

    for (var doc in offers.docs) {
      await doc.reference.delete();
    }

    await _loadData();
  }

  Future<void> _removeOffer(String docId) async {
    await FirebaseFirestore.instance.collection('offers').doc(docId).delete();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: 22, // slightly larger
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage restaurants below:',
                      style: TextStyle(
                        fontSize: 18,
                      ), // larger font, left-aligned
                    ),

                    const SizedBox(height: 16),
                    Column(
                      children:
                          _restaurants.map((restaurant) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        restaurant['image'].isNotEmpty
                                            ? NetworkImage(restaurant['image'])
                                            : null,
                                    radius: 25,
                                    child:
                                        restaurant['image'].isEmpty
                                            ? const Icon(Icons.person, size: 30)
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      restaurant['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => _removeRestaurant(
                                          restaurant['uid'],
                                        ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red.shade100,
                                    ),
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'All Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children:
                          _offers.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Unnamed';
                            final poster = data['posted_by'] ?? 'Unknown';
                            final timestamp =
                                (data['timestamp'] as Timestamp?)?.toDate();
                            final formattedDate =
                                timestamp != null
                                    ? DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(timestamp)
                                    : 'Unknown';
                            return ListTile(
                              title: Text(name),
                              subtitle: Text('$poster Â· $formattedDate'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeOffer(doc.id),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
    );
  }
}
