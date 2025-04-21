import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCeHnP0cAxg5p3QnPvAkWiZIe_QxmE5pEM",
        authDomain: "opotato-14b58.firebaseapp.com",
        projectId: "opotato-14b58",
        storageBucket: "opotato-14b58.firebasestorage.app",
        messagingSenderId: "740988160267",
        appId: "1:740988160267:web:ad95380e2cdec40b907a0e",
        measurementId: "G-DVCSJ3R1RQ",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPotato',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
