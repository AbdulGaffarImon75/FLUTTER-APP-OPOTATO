// lib/controllers/rewards_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'user_controller.dart';

class RewardsController {
  final UserController _userCtrl = UserController();

  /// Fetch the current user’s points balance.
  Future<int> fetchPoints() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    return _userCtrl.fetchRewardPoints(uid);
  }

  /// Redeem [points] from the user’s balance. Returns true on success.
  Future<bool> redeemPoints(int points) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    return _userCtrl.redeemRewardPoints(uid, points);
  }

  /// Generate a simple coupon code.
  String generateCouponCode() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = (ts % 10000).toString().padLeft(4, '0');
    return 'OP10-$rnd';
  }
}
