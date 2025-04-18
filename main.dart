import 'package:flutter/material.dart';
import 'pages/bottom_nav_bar.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/profile_page.dart';
import 'pages/profile_edit_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPotato',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      initialRoute: '/login',
      routes: {
        // used for test but in reality only login will be used
        '/navbar': (context) => const BottomNavBar(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile_edit': (context) => const EditProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
