import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_edit_page.dart';
import 'bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:O_potato/user_service.dart';
import 'package:O_potato/pages/topbar/following_page.dart';
import 'package:O_potato/pages/topbar/check_in_page.dart';
import 'package:O_potato/pages/topbar/bookmark_page.dart';
import 'restaurant_view_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String adminUID = '9augevirHjVzo8izlXsJba568782';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.delayed(
        Duration.zero,
        () => Navigator.pushReplacementNamed(context, '/login'),
      );
      return const Scaffold();
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: UserService().getUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: \${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        var userData = snapshot.data!.data()!;
        String displayName = userData['name'] ?? "No Name";
        String email = user.email ?? "No Email";
        String phoneNumber = userData['phone'] ?? "No Phone Number";
        String? profileImageUrl = userData['profile_image_url'];
        String? userType =
            user.uid == adminUID ? 'admin' : userData['user_type'] ?? 'unknown';

        final List<_ProfileRoute> routes =
            userType == 'customer'
                ? [
                  _ProfileRoute(
                    'Following Restaurants',
                    Icons.favorite,
                    const FollowingPage(),
                  ),
                  _ProfileRoute(
                    'Check-Ins',
                    Icons.directions_walk,
                    const CheckInPage(),
                  ),
                  _ProfileRoute(
                    'Bookmarks',
                    Icons.bookmark,
                    const BookmarkPage(),
                  ),
                  _ProfileRoute('Favorites', Icons.star, const FollowingPage()),
                ]
                : userType == 'restaurant'
                ? [
                  _ProfileRoute(
                    'Customer View',
                    Icons.people,
                    RestaurantViewPage(
                      restaurantId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                ]
                : [];

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                      child:
                          (profileImageUrl == null || profileImageUrl.isEmpty)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      phoneNumber,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton(
                      onPressed: () => openPage(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  for (final item in routes)
                    _buildProfileItem(
                      context,
                      item.title,
                      item.icon,
                      routeWidget: item.widget,
                    ),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    context,
                    'Log Out',
                    Icons.logout,
                    isLogout: true,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavBar(activeIndex: 4),
        );
      },
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLogout = false,
    Widget? routeWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap:
            isLogout
                ? () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
                : routeWidget != null
                ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => routeWidget),
                )
                : null,
      ),
    );
  }

  void openPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }
}

class _ProfileRoute {
  final String title;
  final IconData icon;
  final Widget widget;

  _ProfileRoute(this.title, this.icon, this.widget);
}
