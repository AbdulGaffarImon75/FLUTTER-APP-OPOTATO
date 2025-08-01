import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/navigation_controller.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/restaurant_dashboard.dart';
import 'admin_dashboard_page.dart';
import '../pages/seat_booking_page.dart';
import 'gemini_chatbot_page.dart';
import '../pages/notification_page.dart';
import '../pages/restaurant_notification_page.dart';

class BottomNavBar extends StatefulWidget {
  final int activeIndex;
  const BottomNavBar({super.key, this.activeIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final NavigationController _navController = NavigationController();
  String? _userType;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    // Fetch current user and userType
    _user = _navController.getCurrentUser();
    final type = await _navController.getUserType();
    if (!mounted) return;
    setState(() {
      _userType = type;
    });
  }

  void _onFastFoodTap(BuildContext context) {
    if (_user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }
    switch (_userType) {
      case 'admin':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
        break;
      case 'restaurant':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RestaurantDashboardPage()),
        );
        break;
      case 'customer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GeminiChatPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User type unknown or missing')),
        );
    }
  }

  void _onNotificationTap(BuildContext context) {
    if (_user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }
    if (_userType == 'customer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
    } else if (_userType == 'restaurant') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantNotificationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications unavailable for this user type'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconForHome() {
      switch (_userType) {
        case 'admin':
          return Icons.admin_panel_settings;
        case 'restaurant':
          return Icons.fastfood;
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
            // Dynamic first icon
            if (_userType != null)
              IconButton(
                icon: Icon(iconForHome()),
                color: widget.activeIndex == 0 ? Colors.purple : Colors.grey,
                onPressed: () => _onFastFoodTap(context),
              ),

            // Seat booking
            IconButton(
              icon: const Icon(Icons.event_seat),
              color: widget.activeIndex == 1 ? Colors.purple : Colors.grey,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SeatBookingPage()),
                  ),
            ),

            // Home
            IconButton(
              icon: const Icon(Icons.home_filled),
              color: widget.activeIndex == 2 ? Colors.purple : Colors.grey,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
            ),

            // Notifications
            IconButton(
              icon: const Icon(Icons.notifications),
              color: widget.activeIndex == 3 ? Colors.purple : Colors.grey,
              onPressed: () => _onNotificationTap(context),
            ),

            // Profile / Login
            IconButton(
              icon: const Icon(Icons.person),
              color: widget.activeIndex == 4 ? Colors.purple : Colors.grey,
              onPressed: () {
                if (_navController.getCurrentUser() != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
