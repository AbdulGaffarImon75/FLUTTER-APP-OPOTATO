import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';
import 'package:O_potato/pages/seat_booking.dart';
import 'package:O_potato/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'following_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final UserService _userService = UserService();
  int _points = 0;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    if (userId == null) return;
    try {
      final points = await _userService.getPoints(userId!);
      setState(() => _points = points);
    } catch (e) {
      print('Error loading points: $e');
      setState(() => _points = 0);
    }
  }
  String generateCouponCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch; // Get current timestamp
    final random = (timestamp % 10000).toString().padLeft(4, '0'); // Generate a random part of the code
    return 'OP10-$random'; // Create coupon code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Loyalty & Rewards',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'You have $_points points',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Earn points for your actions and redeem them for exclusive rewards!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  rewardTile(
                    icon: Icons.star_border,
                    title: 'Book a Reservation',
                    points: '+50 points',
                    subtitle: 'Every successful booking earns you 50 points.',
                    onTap: () async {
                      // Just navigate to booking page, no points added here
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SeatBookingPage()),
                      );
                      // Refresh points in case they earned some by booking
                      _loadPoints();
                    },
                  ),


                  const SizedBox(height: 16),
                  rewardTile(
                    icon: Icons.rate_review_outlined,
                    title: 'Leave a Review',
                    points: '+30 points',
                    subtitle: 'Write honest reviews and earn points.',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FollowingPage()),
                      );
                      _loadPoints();
                      
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Redeem Your Points',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  rewardTile(
                    icon: Icons.local_offer_outlined,
                    title: '10% Off Coupon',
                    points: 'Redeem for 500 points',
                    subtitle: 'Use at your favorite restaurant.',
                    onTap: () async {
                      if (_points < 500) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not enough points')),
                        );
                        return;
                      }

                      // Attempt to redeem points
                      final success = await _userService.redeemPoints(userId!, 500);
                      if (success) {
                        // After successful redemption, update the points locally
                        _loadPoints(); // This will fetch the updated points from Firestore and trigger a setState
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coupon redeemed!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to redeem coupon')),
                        );
                      }

                      // Generate the coupon code
                      String couponCode = generateCouponCode();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('10% Off Coupon'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Show this code at the counter to get 10% off:'),
                              SizedBox(height: 12),
                              SelectableText(
                                couponCode, // Show the dynamically generated code
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                    },

                  ),

                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(activeIndex: 2), // Set correct active index
            ),
          ],
        ),
      ),
    );
  }

  Widget rewardTile({
    required IconData icon,
    required String title,
    required String points,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              points,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
