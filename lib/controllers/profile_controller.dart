// controllers/profile_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/pages/topbar/following_page.dart';
import '../views/pages/topbar/check_in_page.dart';
import '../views/pages/topbar/bookmark_page.dart';
import '../views/pages/restaurant_view_page.dart';
import '../views/pages/profile_edit_page.dart';
import '../views/pages/login_page.dart';
import '../views/pages/topbar/combos_page.dart';
import '../views/pages/topbar/rewards_page.dart';
import '../views/pages/topbar/offers_page.dart';
import '../views/pages/topbar/check_in_page.dart';
import '../views/pages/payment_page.dart';
import 'package:flutter/material.dart';

class ProfileController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  static const adminUID = '9augevirHjVzo8izlXsJba568782';

  Future<UserModel?> fetchUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _db.collection('users').doc(u.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserModel.fromMap(u.uid, {
      ...data,
      'email': u.email ?? '',
      'user_type': u.uid == adminUID ? 'admin' : data['user_type'],
    });
  }

  List<ProfileRoute> routesFor(UserModel u) {
    if (u.userType == 'customer') {
      return [
        ProfileRoute(
          'Following Restaurants',
          Icons.favorite,
          const FollowingPage(),
        ),
        ProfileRoute('Check-Ins', Icons.directions_walk, const CheckInPage()),
        ProfileRoute('Bookmarks', Icons.bookmark, const BookmarkPage()),
        ProfileRoute('Rewards', Icons.star, const RewardsPage()),
      ];
    }
    if (u.userType == 'restaurant') {
      return [
        ProfileRoute(
          'My Restaurant',
          Icons.home,
          RestaurantViewPage(restaurantId: u.uid),
        ),
        ProfileRoute('Combos', Icons.local_offer, const CombosPage()),
        ProfileRoute('Offers', Icons.local_offer, const OffersPage()),
        ProfileRoute('Payment', Icons.payment, const PaymentPage()),
      ];
    }
    // admin or unknown: show nothing
    return [];
  }

  Future<void> signOut() => _auth.signOut();
}

class ProfileRoute {
  final String title;
  final IconData icon;
  final Widget page;
  ProfileRoute(this.title, this.icon, this.page);
}
