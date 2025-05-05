import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class RestaurantDashboardPage extends StatefulWidget {
  const RestaurantDashboardPage({super.key});

  @override
  State<RestaurantDashboardPage> createState() =>
      _RestaurantDashboardPageState();
}

class _RestaurantDashboardPageState extends State<RestaurantDashboardPage> {
  final TextEditingController _offerNameController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _seatStatusController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? profileImageUrl;
  String? restaurantName;
  String? restaurantUID;

  int totalSeats = 30;
  int availableSeats = 0;
  List<DocumentSnapshot> _restaurantOffers = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      restaurantUID = user.uid;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final userData = userDoc.data();

      if (userData != null) {
        restaurantName = userData['name'];
        profileImageUrl = userData['profile_image_url'];

        final restDoc = FirebaseFirestore.instance
            .collection('rest')
            .doc(user.uid);
        final restSnapshot = await restDoc.get();

        if (!restSnapshot.exists) {
          await restDoc.set({
            'name': restaurantName,
            'available seats': 0,
            'total seats': totalSeats,
          });
        } else {
          final data = restSnapshot.data()!;
          availableSeats = data['available seats'] ?? 0;
          totalSeats = data['total seats'] ?? 30;
        }

        await _fetchRestaurantOffers();
        setState(() {});
      }
    }
  }

  Future<void> _postOffer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final offerData = {
        'name': _offerNameController.text,
        'price': '৳${_offerPriceController.text}',
        'imageURL': _imageUrlController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'posted_by': restaurantName ?? '',
        'posted_by_id': restaurantUID ?? '',
        'profile_image_url': profileImageUrl ?? '',
      };

      await FirebaseFirestore.instance.collection('offers').add(offerData);

      _offerNameController.clear();
      _offerPriceController.clear();
      _seatStatusController.clear();
      _imageUrlController.clear();

      await _fetchRestaurantOffers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer posted successfully!')),
      );
    }
  }

  Future<void> _updateSeats() async {
    final input = int.tryParse(_seatStatusController.text.trim());
    if (input == null) return;

    final newSeats = availableSeats + input;

    if (newSeats > totalSeats) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sorry! Over your capacity!')));
      return;
    }

    await FirebaseFirestore.instance
        .collection('rest')
        .doc(restaurantUID)
        .update({'available seats': newSeats});

    setState(() {
      availableSeats = newSeats;
    });

    _seatStatusController.clear();

    if (availableSeats > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seats updated successfully')),
      );
    }
  }

  Future<void> _fetchRestaurantOffers() async {
    if (restaurantName == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('offers')
            .where('posted_by', isEqualTo: restaurantName)
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _restaurantOffers = snapshot.docs;
    });
  }

  Future<void> _deleteOffer(String docId) async {
    await FirebaseFirestore.instance.collection('offers').doc(docId).delete();
    await _fetchRestaurantOffers();
  }

  @override
  void dispose() {
    _offerNameController.dispose();
    _offerPriceController.dispose();
    _seatStatusController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : null,
                child:
                    (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 12),
            if (restaurantName != null)
              Center(
                child: Text(
                  restaurantName!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Post Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _offerNameController,
              decoration: const InputDecoration(
                labelText: 'Offer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _offerPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _postOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('POST'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Update Seat Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seatStatusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Add Seats',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateSeats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('UPDATE'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Available Seats: $availableSeats'),
            Text('Total Seats: $totalSeats'),
            const SizedBox(height: 24),
            const Text(
              'Offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_restaurantOffers.isEmpty)
              const Text('No offers posted yet.')
            else
              Column(
                children:
                    _restaurantOffers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? '';
                      final timestamp =
                          (data['timestamp'] as Timestamp?)?.toDate();
                      final formattedDate =
                          timestamp != null
                              ? DateFormat('MMM d, h:mm a').format(timestamp)
                              : 'Unknown';

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(formattedDate),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOffer(doc.id),
                        ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
    );
  }
}
