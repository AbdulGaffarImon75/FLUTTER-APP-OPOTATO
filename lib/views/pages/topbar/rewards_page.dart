import 'package:flutter/material.dart';
import '/../controllers/rewards_controller.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';
import 'package:O_potato/views/pages/seat_booking_page.dart';
import 'following_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final _ctrl = RewardsController();
  late Future<int> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _pointsFuture = _ctrl.fetchPoints();
  }

  Future<void> _refreshPoints() async {
    // 1. Kick off the fetch asynchronously
    final newFuture = _ctrl.fetchPoints();
    // 2. Then update the state synchronously
    setState(() {
      _pointsFuture = newFuture;
    });
  }

  void _onRedeem(BuildContext context) async {
    final success = await _ctrl.redeemPoints(500);
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough points')));
      return;
    }
    final code = _ctrl.generateCouponCode();
    await _refreshPoints();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('10% Off Coupon'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Show this code at the counter to get 10% off:'),
                const SizedBox(height: 12),
                SelectableText(
                  code,
                  style: const TextStyle(
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
  }

  Widget _rewardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String pointsLabel,
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
              pointsLabel,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SafeArea(
        child: FutureBuilder<int>(
          future: _pointsFuture,
          builder: (context, snap) {
            final pts = snap.data ?? 0;
            return SingleChildScrollView(
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
                      'You have $pts points',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'Earn points for your actions and redeem them for exclusive rewards!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _rewardTile(
                    icon: Icons.star_border,
                    title: 'Book a Reservation',
                    subtitle: 'Every successful booking earns you 50 points.',
                    pointsLabel: '+50 points',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SeatBookingPage(),
                        ),
                      );
                      await _refreshPoints();
                    },
                  ),
                  const SizedBox(height: 16),
                  _rewardTile(
                    icon: Icons.rate_review_outlined,
                    title: 'Leave a Review',
                    subtitle: 'Write honest reviews and earn points.',
                    pointsLabel: '+30 points',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowingPage(),
                        ),
                      );
                      await _refreshPoints();
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Redeem Your Points',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _rewardTile(
                    icon: Icons.local_offer_outlined,
                    title: '10% Off Coupon',
                    subtitle: 'Use at your favorite restaurant.',
                    pointsLabel: 'Redeem for 500 points',
                    onTap: () => _onRedeem(context),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
