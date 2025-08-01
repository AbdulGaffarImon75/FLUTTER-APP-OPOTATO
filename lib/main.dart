import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'views/pages/home_page.dart';
import 'views/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyCeHnP0cAxg5p3QnPvAkWiZIe_QxmE5pEM",
          authDomain: "opotato-14b58.firebaseapp.com",
          projectId: "opotato-14b58",
          storageBucket: "opotato-14b58.appspot.com",
          messagingSenderId: "740988160267",
          appId: "1:740988160267:web:ad95380e2cdec40b907a0e",
          measurementId: "G-DVCSJ3R1RQ",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  Gemini.init(apiKey: 'AIzaSyBvJmmpco-TW3KL4aqUCnGJDdKyHQn5_M8');

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
