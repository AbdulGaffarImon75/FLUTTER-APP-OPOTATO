import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'bottom_nav_bar.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;
  const ReviewPage({super.key, required this.restaurantId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _isCustomer = false;
  String? _customerName;
  String? _customerImage;
  String? _restaurantName;
  String? _restaurantImage;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkCustomer();
    _loadRestaurantInfo();
  }

  Future<void> _checkCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data();
    if (data?['user_type'] == 'customer') {
      setState(() {
        _isCustomer = true;
        _customerName = data?['name'] ?? '';
        _customerImage = data?['profile_image_url'];
      });
    }
  }

  Future<void> _loadRestaurantInfo() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.restaurantId)
            .get();
    final data = doc.data();
    setState(() {
      _restaurantName = data?['name'] ?? 'Restaurant';
      _restaurantImage = data?['profile_image_url'];
    });
  }

  Future<void> _postReview() async {
    final text = _controller.text.trim();
    if (!_isCustomer || text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    final reviewRef = FirebaseFirestore.instance
        .collection('rest')
        .doc(widget.restaurantId)
        .collection('reviews');

    await reviewRef.add({
      'userId': user.uid,
      'userName': _customerName ?? '',
      'userImage': _customerImage ?? '',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();

    try {
      await FirebaseFirestore.instance
          .collection('user_points')
          .doc(user.uid)
          .set({'points': FieldValue.increment(30)}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('+30 points added for your review!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review posted, but failed to add points')),
        );
      }
    }
  }


  String _formatDateWithSuffix(DateTime date) {
    final day = date.day;
    String suffix;
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else if (day % 10 == 1) {
      suffix = 'st';
    } else if (day % 10 == 2) {
      suffix = 'nd';
    } else if (day % 10 == 3) {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }
    final monthYear = DateFormat('MMMM yyyy').format(date);
    return '$day$suffix $monthYear';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 1. white background
      appBar: AppBar(
        title: Text(_restaurantName ?? 'Reviews'),
        backgroundColor: const Color.fromARGB(
          255,
          191,
          160,
          244,
        ), // match background
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: Column(
        children: [
          // 3. restaurant image at top center
          if (_restaurantImage != null && _restaurantImage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _restaurantImage!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _restaurantName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          // 2. reviews list with same background (white)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('rest')
                      .doc(widget.restaurantId)
                      .collection('reviews')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reviews yet.'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final userImage = data['userImage'] as String?;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final dateString =
                        timestamp != null
                            ? _formatDateWithSuffix(
                              timestamp.toDate().toLocal(),
                            )
                            : '';
                    return Card(
                      color: const Color.fromARGB(
                        255,
                        233,
                        185,
                        244,
                      ), // tile same as background
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              (userImage != null && userImage.isNotEmpty)
                                  ? NetworkImage(userImage)
                                  : null,
                          child:
                              (userImage == null || userImage.isEmpty)
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                        title: Text(data['userName'] ?? 'Anonymous'),
                        subtitle: Text(data['text'] ?? ''),
                        trailing: Text(
                          dateString,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // 4 & 5. post review button white background, white text
          if (_isCustomer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write your review...',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        elevation: 0,
                      ),
                      child: const Text('Post Review'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
