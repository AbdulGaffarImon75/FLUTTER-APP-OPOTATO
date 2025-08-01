// lib/views/pages/checkin_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../controllers/checkin_controller.dart';
import '/../models/checkin_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';
import 'package:O_potato/views/pages/restaurant_view_page.dart';

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = CheckInController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Check-Ins'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: FutureBuilder<List<CheckIn>>(
        future: ctrl.fetchUserCheckIns(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No check-ins found."));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final c = items[i];
              final formatted = DateFormat(
                'MMM d, yyyy – h:mm a',
              ).format(c.timestamp);
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => RestaurantViewPage(
                              restaurantId: c.restaurantId,
                            ),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 237, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            c.imageUrl.isNotEmpty
                                ? NetworkImage(c.imageUrl)
                                : null,
                        child:
                            c.imageUrl.isEmpty
                                ? const Icon(Icons.store, size: 30)
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.restaurantName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatted,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
