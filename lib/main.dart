import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart'; // <-- NEW: for PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'views/pages/home_page.dart';
import 'views/pages/login_page.dart';

/// NEW: Allow drag scrolling with mouse/trackpad as well as touch.
/// This makes horizontal ListViews draggable on web/desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
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
    debugPrint("Firebase initialization failed: $e");
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },

      // NEW: enable dragging scrollables with mouse/trackpad on web
      scrollBehavior: const AppScrollBehavior(),

      // Existing: phone-box the whole app on web so it stays mobile-sized
      builder: (context, child) {
        if (!kIsWeb || child == null) return child ?? const SizedBox();

        const phoneWidth = 390.0; // pick the mobile width you designed for

        return ColoredBox(
          color: const Color(0xFFF5F5F7), // bg outside the "device"
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: phoneWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  // keep ink/elevation after clipping
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
