// views/pages/profile_page.dart

import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_model.dart';
import 'bottom_nav_bar.dart';
import 'profile_edit_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _ctrl = ProfileController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _ctrl.fetchUser(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user == null) {
          // not logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          });
          return const Scaffold();
        }
        final routes = _ctrl.routesFor(user);
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          style: TextStyle(color: Colors.blue),
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
                          user.profileImageUrl.isNotEmpty
                              ? NetworkImage(user.profileImageUrl)
                              : null,
                      child:
                          user.profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      user.phone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...routes.map((r) => _buildItem(context, r)),
                  const SizedBox(height: 24),
                  _buildItem(
                    context,
                    ProfileRoute('Log Out', Icons.logout, const SizedBox()),
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

  Widget _buildItem(BuildContext ctx, ProfileRoute r, {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: Icon(r.icon, color: isLogout ? Colors.red : Colors.black),
        title: Text(
          r.title,
          style: TextStyle(color: isLogout ? Colors.red : Colors.black),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (isLogout) {
            _ctrl.signOut().then((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            });
          } else {
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => r.page));
          }
        },
      ),
    );
  }
}
