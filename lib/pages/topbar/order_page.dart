import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_nav_bar.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

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
