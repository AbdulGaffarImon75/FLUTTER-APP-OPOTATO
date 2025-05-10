import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';
import 'package:O_potato/pages/seat_booking.dart';
import 'following_page.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SeatBookingPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  rewardTile(
                    icon: Icons.rate_review_outlined,
                    title: 'Leave a Review',
                    points: '+30 points',
                    subtitle: 'Write honest reviews and earn points.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowingPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  rewardTile(
                    icon: Icons.location_on_outlined,
                    title: 'Check In at Restaurant',
                    points: '+20 points',
                    subtitle: 'Earn points just for showing up!',
                    onTap: () {
                      // TODO: handle tap
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
                    points: 'Redeem for 100 points',
                    subtitle: 'Use at your favorite restaurant.',
                    onTap: () {
                      // TODO: handle tap
                    },
                  ),
                  const SizedBox(height: 16),
                  rewardTile(
                    icon: Icons.free_breakfast_outlined,
                    title: 'Free Dessert',
                    points: 'Redeem for 150 points',
                    subtitle: 'Get a sweet treat with your next order.',
                    onTap: () {
                      // TODO: handle tap
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
