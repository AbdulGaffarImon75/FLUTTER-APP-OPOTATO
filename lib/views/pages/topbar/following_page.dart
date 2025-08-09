// lib/views/pages/following_page.dart

import 'package:flutter/material.dart';
import '/../controllers/following_controller.dart';
import '/../models/restaurant_follow_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';
import 'package:O_potato/views/pages/restaurant_view_page.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final _ctrl = FollowingController();
  late Future<List<RestaurantFollow>> _futureList;

  @override
  void initState() {
    super.initState();
    _futureList = _ctrl.fetchRestaurantsWithFollowStatus();
  }

  Future<void> _onToggle(String uid) async {
    await _ctrl.toggleFollow(uid);
    setState(() {
      _futureList = _ctrl.fetchRestaurantsWithFollowStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Restaurants'), centerTitle: true),
      body: FutureBuilder<List<RestaurantFollow>>(
        future: _futureList,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final r = list[i];
              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantViewPage(restaurantId: r.uid),
                      ),
                    ),
                child: Container(
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
                        radius: 25,
                        backgroundImage:
                            r.imageUrl.isNotEmpty
                                ? NetworkImage(r.imageUrl)
                                : null,
                        child:
                            r.imageUrl.isEmpty
                                ? const Icon(Icons.person, size: 30)
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          r.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _onToggle(r.uid),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              r.isFollowing
                                  ? Colors.grey.shade300
                                  : Colors.green,
                          minimumSize: const Size(80, 30),
                        ),
                        child: Text(
                          r.isFollowing ? 'Unfollow' : 'Follow',
                          style: TextStyle(
                            color: r.isFollowing ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
