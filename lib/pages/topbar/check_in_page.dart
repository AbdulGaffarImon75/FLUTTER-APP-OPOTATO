import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Burgers'), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16)),
    );
  }
}
