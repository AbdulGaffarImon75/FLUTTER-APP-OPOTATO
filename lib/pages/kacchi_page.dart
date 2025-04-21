import 'package:flutter/material.dart';

class KacchiPage extends StatelessWidget {
  const KacchiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('KACCHI'), centerTitle: true),
      body: Center(
        child: Text('Welcome to KACCHI Page!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
