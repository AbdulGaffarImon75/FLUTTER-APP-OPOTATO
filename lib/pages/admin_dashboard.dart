import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 191, 160, 244),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Use the options below to manage users, monitor activity, and update platform settings.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 32),
            // Future buttons or admin options will go here
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
    );
  }
}
