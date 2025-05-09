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
  // final TextEditingController _seatStatusController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final TextEditingController _comboTitleController = TextEditingController();
  final TextEditingController _comboPriceController = TextEditingController();
  final TextEditingController _comboImageUrlController =
      TextEditingController();

  final TextEditingController _add2Controller = TextEditingController();
  final TextEditingController _add4Controller = TextEditingController();
  final TextEditingController _add8Controller = TextEditingController();
  final TextEditingController _add12Controller = TextEditingController();

  String? profileImageUrl;
  String? restaurantName;
  String? restaurantUID;

  int totalSeats = 76;
  int availableSeats = 0;
  int twoSeat = 0, fourSeat = 0, eightSeat = 0, twelveSeat = 0;
  List<DocumentSnapshot> _restaurantOffers = [];
  List<DocumentSnapshot> _restaurantCombos = [];

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
            'available seats': totalSeats,
            'total seats': totalSeats,
            '2_people_seat': 12,
            '4_people_seat': 16,
            '8_people_seat': 24,
            '12_people_seat': 24,
          });
        } else {
          final data = restSnapshot.data()!;
          availableSeats = data['available seats'] ?? 0;
          twoSeat = data['2_people_seat'] ?? 0;
          fourSeat = data['4_people_seat'] ?? 0;
          eightSeat = data['8_people_seat'] ?? 0;
          twelveSeat = data['12_people_seat'] ?? 0;
        }

        await _fetchRestaurantOffers();
        await _fetchRestaurantCombos();
        setState(() {});
      }
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

  Future<void> _fetchRestaurantCombos() async {
    if (restaurantName == null) return;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('combos')
            .where('vendor', isEqualTo: restaurantName)
            .orderBy('timestamp', descending: true)
            .get();
    setState(() {
      _restaurantCombos = snapshot.docs;
    });
  }

  Future<void> _postOffer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final offerData = {
        'name': _offerNameController.text,
        'price': 'à§³${_offerPriceController.text}',
        'imageURL': _imageUrlController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'posted_by': restaurantName ?? '',
        'posted_by_id': restaurantUID ?? '',
        'profile_image_url': profileImageUrl ?? '',
      };

      await FirebaseFirestore.instance.collection('offers').add(offerData);
      _offerNameController.clear();
      _offerPriceController.clear();
      _imageUrlController.clear();
      await _fetchRestaurantOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer posted successfully!')),
      );
    }
  }

  Future<void> _postCombo() async {
    final comboData = {
      'title': _comboTitleController.text,
      'price': _comboPriceController.text,
      'imageURL': _comboImageUrlController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'vendor': restaurantName ?? '',
    };
    await FirebaseFirestore.instance.collection('combos').add(comboData);
    _comboTitleController.clear();
    _comboPriceController.clear();
    _comboImageUrlController.clear();
    await _fetchRestaurantCombos();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Combo posted successfully!')));
  }

  Future<void> _updateSeats() async {
    int add2 = int.tryParse(_add2Controller.text.trim()) ?? 0;
    int add4 = int.tryParse(_add4Controller.text.trim()) ?? 0;
    int add8 = int.tryParse(_add8Controller.text.trim()) ?? 0;
    int add12 = int.tryParse(_add12Controller.text.trim()) ?? 0;

    int new2 = twoSeat + add2;
    int new4 = fourSeat + add4;
    int new8 = eightSeat + add8;
    int new12 = twelveSeat + add12;

    int newAvailable = new2 + new4 + new8 + new12;

    if (newAvailable > totalSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry! Over your capacity!')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('rest')
        .doc(restaurantUID)
        .update({
          '2_people_seat': new2,
          '4_people_seat': new4,
          '8_people_seat': new8,
          '12_people_seat': new12,
          'available seats': newAvailable,
        });

    setState(() {
      twoSeat = new2;
      fourSeat = new4;
      eightSeat = new8;
      twelveSeat = new12;
      availableSeats = newAvailable;
    });

    _add2Controller.clear();
    _add4Controller.clear();
    _add8Controller.clear();
    _add12Controller.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Seats updated successfully')));
  }

  Future<void> _deleteOffer(String docId) async {
    await FirebaseFirestore.instance.collection('offers').doc(docId).delete();
    await _fetchRestaurantOffers();
  }

  Future<void> _deleteCombo(String docId) async {
    await FirebaseFirestore.instance.collection('combos').doc(docId).delete();
    await _fetchRestaurantCombos();
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
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
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
                    profileImageUrl?.isNotEmpty == true
                        ? NetworkImage(profileImageUrl!)
                        : null,
                child:
                    profileImageUrl?.isEmpty ?? true
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _postOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 191, 160, 244),
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 0),
              ),
              child: const Text('POST'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Post Combo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comboTitleController,
              decoration: const InputDecoration(
                labelText: 'Combo Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comboPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comboImageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _postCombo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 191, 160, 244),
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 0),
              ),
              child: const Text('POST'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Update Seat Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSeatField('Add 2-Person Seats', _add2Controller),
            const SizedBox(height: 12),
            _buildSeatField('Add 4-Person Seats', _add4Controller),
            const SizedBox(height: 12),
            _buildSeatField('Add 8-Person Seats', _add8Controller),
            const SizedBox(height: 12),
            _buildSeatField('Add 12-Person Seats', _add12Controller),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _updateSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text('UPDATE'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Available Seats: $availableSeats'),
            Text('Total Seats: $totalSeats'),
            Text('2-Person Seats: $twoSeat'),
            Text('4-Person Seats: $fourSeat'),
            Text('8-Person Seats: $eightSeat'),
            Text('12-Person Seats: $twelveSeat'),
            const SizedBox(height: 24),
            const Text(
              'Offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ..._restaurantOffers.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
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
            }),
            const SizedBox(height: 24),
            const Text(
              'Combos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ..._restaurantCombos.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedDate =
                  timestamp != null
                      ? DateFormat('MMM d, h:mm a').format(timestamp)
                      : 'Unknown';
              return ListTile(
                title: Text(title),
                subtitle: Text(formattedDate),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCombo(doc.id),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

Widget _buildSeatField(String label, TextEditingController controller) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
