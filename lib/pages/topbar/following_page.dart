import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_nav_bar.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>> _restaurants = [];
  Set<String> _followedIds = {};
  bool _isLoading = true;
  bool _isCustomer = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    final userType = userDoc.data()?['user_type'] ?? '';
    if (userType != 'customer') {
      setState(() {
        _isCustomer = false;
        _isLoading = false;
      });
      return;
    }
    _isCustomer = true;

    final followedSnapshot =
        await FirebaseFirestore.instance
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .get();

    _followedIds = followedSnapshot.docs.map((doc) => doc.id).toSet();

    final allRestaurantsSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();

    final restaurants =
        allRestaurantsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'name': data['name'] ?? 'Unnamed',
            'image': data['profile_image_url'] ?? '',
            'isFollowing': _followedIds.contains(doc.id),
          };
        }).toList();

    restaurants.sort((a, b) {
      if (a['isFollowing'] && !b['isFollowing']) return -1;
      if (!a['isFollowing'] && b['isFollowing']) return 1;
      return a['name'].compareTo(b['name']);
    });

    setState(() {
      _restaurants = restaurants;
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow(String restaurantId) async {
    if (!_isCustomer) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final followRef = FirebaseFirestore.instance
        .collection('following')
        .doc(user.uid)
        .collection('restaurants')
        .doc(restaurantId);

    final isCurrentlyFollowing = _followedIds.contains(restaurantId);

    if (isCurrentlyFollowing) {
      await followRef.delete();
    } else {
      await followRef.set({'timestamp': FieldValue.serverTimestamp()});
    }

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Following'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : !_isCustomer
              ? const Center(
                child: Text('Only customers can follow restaurants.'),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _restaurants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final restaurant = _restaurants[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                          onPressed: () => _toggleFollow(restaurant['uid']),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                restaurant['isFollowing']
                                    ? Colors.grey.shade300
                                    : Colors.green,
                            minimumSize: const Size(80, 30),
                          ),
                          child: Text(
                            restaurant['isFollowing'] ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color:
                                  restaurant['isFollowing']
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
    );
  }
}
