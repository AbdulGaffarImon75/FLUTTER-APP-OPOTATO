import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'menu.dart';
import 'review_page.dart';

class RestaurantViewPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantViewPage({super.key, required this.restaurantId});

  @override
  State<RestaurantViewPage> createState() => _RestaurantViewPageState();
}

class _RestaurantViewPageState extends State<RestaurantViewPage> {
  String? _name;
  String? _image;
  List<DocumentSnapshot> _offers = [];
  List<DocumentSnapshot> _combos = [];
  bool _isCustomer = false;
  bool _isFollowing = false;
  String? _customerName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadRestaurantInfo();
    await _checkUserType();
    await _loadFollowStatus();
    await _fetchRestaurantOffers();
    await _fetchRestaurantCombos();
    setState(() => _loading = false);
  }

  Future<void> _loadRestaurantInfo() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.restaurantId)
            .get();
    final data = doc.data();
    _name = data?['name'] ?? 'Restaurant';
    _image = data?['profile_image_url'] ?? '';
  }

  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userData = userDoc.data();
    if (userData?['user_type'] == 'customer') {
      _isCustomer = true;
      _customerName = userData?['name'];
    }
  }

  Future<void> _loadFollowStatus() async {
    if (!_isCustomer) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('following')
            .doc(user.uid)
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get();

    setState(() {
      _isFollowing = doc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_isCustomer) return;

    final followRef = FirebaseFirestore.instance
        .collection('following')
        .doc(user.uid)
        .collection('restaurants')
        .doc(widget.restaurantId);

    final restaurantDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.restaurantId)
            .get();
    final restaurantName = restaurantDoc.data()?['name'] ?? 'Restaurant';

    if (_isFollowing) {
      await followRef.delete();
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.restaurantId)
          .collection('messages')
          .add({
            'message':
                'Dear $restaurantName, $_customerName has just unfollowed you.',
            'timestamp': FieldValue.serverTimestamp(),
          });
    } else {
      await followRef.set({'timestamp': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.restaurantId)
          .collection('messages')
          .add({
            'message':
                'Dear $restaurantName, $_customerName has started following you.',
            'timestamp': FieldValue.serverTimestamp(),
          });
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  Future<void> _fetchRestaurantOffers() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .where('posted_by_id', isEqualTo: widget.restaurantId)
            .orderBy('timestamp', descending: true)
            .get();
    setState(() => _offers = snapshot.docs);
  }

  Future<void> _fetchRestaurantCombos() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('combos')
            .where('vendor', isEqualTo: _name)
            .orderBy('timestamp', descending: true)
            .get();
    setState(() => _combos = snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name ?? 'Restaurant'),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Name
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              _image != null && _image!.isNotEmpty
                                  ? NetworkImage(_image!)
                                  : null,
                          child:
                              (_image == null || _image!.isEmpty)
                                  ? const Icon(Icons.store, size: 40)
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _name ?? 'Restaurant',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Buttons: Menu, Review, Follow/Unfollow
                    Row(
                      children: [
                        _buildActionButton('Menu', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MenuPage(
                                    restaurantId: widget.restaurantId,
                                  ),
                            ),
                          );
                        }),
                        const SizedBox(width: 12),
                        _buildActionButton('Reviews', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ReviewPage(
                                    restaurantId: widget.restaurantId,
                                  ),
                            ),
                          );
                        }),
                        if (_isCustomer) ...[
                          const SizedBox(width: 12),
                          _buildActionButton(
                            _isFollowing ? 'Unfollow' : 'Follow',
                            _toggleFollow,
                            backgroundColor:
                                _isFollowing
                                    ? Colors.grey.shade300
                                    : Colors.green,
                            textColor:
                                _isFollowing ? Colors.black : Colors.white,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Offers
                    const Text(
                      'Offers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._offers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        color: const Color.fromARGB(255, 245, 237, 255),
                        child: ListTile(
                          leading: Image.network(
                            data['imageURL'],
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(data['name']),
                          subtitle: Text(data['price']),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Combos
                    const Text(
                      'Combos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._combos.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        color: const Color.fromARGB(255, 245, 237, 255),
                        child: ListTile(
                          leading: Image.network(
                            data['imageURL'],
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(data['title']),
                          subtitle: Text("৳${data['price']}"),
                        ),
                      );
                    }),
                  ],
                ),
              ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed, {
    Color backgroundColor = const Color.fromARGB(255, 230, 220, 250),
    Color textColor = Colors.black,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
