import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:O_potato/pages/profile_edit_page.dart';
import 'bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:O_potato/pages/login_page.dart';
import 'package:O_potato/user_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      builder: (
        context,
        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
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
                                profileImageUrl != null &&
                                        profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                            child:
                                (profileImageUrl == null ||
                                        profileImageUrl.isEmpty)
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            phoneNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
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
                        _buildProfileItem(
                          context,
                          'Favourite Restaurants',
                          Icons.favorite,
                        ),
                        _buildProfileItem(
                          context,
                          'Outings',
                          Icons.directions_walk,
                        ),
                        _buildProfileItem(
                          context,
                          'Saved Offers',
                          Icons.local_offer,
                        ),
                        _buildProfileItem(
                          context,
                          'Clear History',
                          Icons.history,
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
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavBar(activeIndex: 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLogout = false,
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
        onTap: isLogout ? () => _logout(context) : () {},
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void openPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }
}
