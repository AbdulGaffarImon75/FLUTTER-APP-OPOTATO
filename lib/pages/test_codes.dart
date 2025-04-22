// // ✅ opotato-api.js (already complete with all endpoints)
// // No change required for backend code. Now adding Flutter-side services and page updates.

// // 🔧 New File: lib/services/user_service.dart

// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Future<void> createUserDocument(String uid, Map<String, dynamic> userData) async {
//     await _db.collection('users').doc(uid).set(userData);
//   }

//   Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
//     return _db.collection('users').doc(uid).get();
//   }

//   Future<void> updateUser(String uid, Map<String, dynamic> data) async {
//     await _db.collection('users').doc(uid).update(data);
//   }
// }

// // 🔧 Update File: lib/auth_service.dart (if not already done)

// // Import user_service.dart
// import 'package:flutter_application_1/services/user_service.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;
//   final _userService = UserService();

//   Future<User?> createUserWithEmailAndPassword(String email, String password) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//       if (cred.user != null) {
//         await _userService.createUserDocument(cred.user!.uid, {
//           'email': email,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       }
//       return cred.user;
//     } catch (e) {
//       print("Auth error: $e");
//       return null;
//     }
//   }

//   Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return cred.user;
//     } catch (e) {
//       print("Login error: $e");
//       return null;
//     }
//   }
// }

// // 🔧 Update: signup_page.dart (only inside _handleSignUp function)

// // Replace the old _handleSignUp function with this:
// Future<void> _handleSignUp() async {
//   if (_passwordController.text != _confirmPasswordController.text) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
//     return;
//   }

//   final user = await _auth.createUserWithEmailAndPassword(
//     _emailController.text.trim(),
//     _passwordController.text.trim(),
//   );

//   if (user != null && mounted) {
//     final userService = UserService();
//     await userService.createUserDocument(user.uid, {
//       'name': _nameController.text.trim(),
//       'number': _numberController.text.trim(),
//       'email': _emailController.text.trim(),
//     });

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const ProfilePage()),
//     );
//   }
// }

// // 🔧 Update: profile_page.dart

// // Change StatelessWidget to StatefulWidget:
// // class ProfilePage extends StatelessWidget {
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   String name = '';
//   String email = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchProfile();
//   }

//   Future<void> fetchProfile() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       final data = doc.data();
//       if (data != null) {
//         setState(() {
//           name = data['name'] ?? '';
//           email = data['email'] ?? '';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 24),
//                     Row(
//                       children: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Back', style: TextStyle(fontSize: 16, color: Colors.blue)),
//                         ),
//                         const Spacer(),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Center(
//                       child: Text('My Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                     ),
//                     const SizedBox(height: 32),
//                     const Center(
//                       child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
//                     ),
//                     const SizedBox(height: 16),
//                     Center(
//                       // const Text('Sabrina Aryan')
//                       child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     ),
//                     const SizedBox(height: 8),
//                     Center(
//                       // const Text('SabrinaAry208@gmail.com')
//                       child: Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
//                     ),
//                     ... // unchanged
//                   ],
//                 ),
//               ),
//             ),
//             const Positioned(bottom: 0, left: 0, right: 0, child: BottomNavBar(activeIndex: 4)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 🔧 Update: edit_profile_page.dart — inside Save button onPressed:

// // Replace:
// // onPressed: () {
// //   // Save profile changes
// // },

// onPressed: () async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     final updatedData = {
//       'name': _nameController.text.trim(),
//       'email': _emailController.text.trim(),
//       'phone': _phoneController.text.trim(),
//     };
//     final userService = UserService();
//     await userService.updateUser(user.uid, updatedData);

//     if (context.mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated')),
//       );
//     }
//   }
// },

// // ✅ Done. All user data is now synced to and from Firestore.
