import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'restaurant_dashboard.dart';
import 'admin_dashboard.dart';
import 'seat_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatbot_page.dart';
import 'notification_page.dart';

class BottomNavBar extends StatefulWidget {
  final int activeIndex;
  static const String adminUID = '9augevirHjVzo8izlXsJba568782';

  const BottomNavBar({super.key, this.activeIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? _userType;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      setState(() {
        _userType = 'guest';
      });
      return;
    }
    if (_user!.uid == BottomNavBar.adminUID) {
      setState(() {
        _userType = 'admin';
      });
      return;
    }
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
    setState(() {
      _userType = doc.data()?['user_type'] ?? 'unknown';
    });
  }

  Future<void> _handleFastFoodTapOptimized(BuildContext context) async {
    if (_user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (_user!.uid == BottomNavBar.adminUID) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
    final userType = doc.data()?['user_type'];

    if (userType == 'customer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    } else if (userType == 'restaurant') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RestaurantDashboardPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User type unknown or missing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData getDynamicIcon() {
      switch (_userType) {
        case 'restaurant':
          return Icons.fastfood;
        case 'admin':
          return Icons.admin_panel_settings;
        case 'customer':
        case 'guest':
        default:
          return Icons.chat;
      }
    }

    return BottomAppBar(
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_userType != null)
              IconButton(
                onPressed: () => _handleFastFoodTapOptimized(context),
                icon: Icon(getDynamicIcon()),
                color: widget.activeIndex == 0 ? Colors.purple : Colors.grey,
              ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeatBookingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.event_seat),
              color: widget.activeIndex == 1 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: const Icon(Icons.home_filled),
              color: widget.activeIndex == 2 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications),
              color: widget.activeIndex == 3 ? Colors.purple : Colors.grey,
            ),
            IconButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.person),
              color: widget.activeIndex == 4 ? Colors.purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
