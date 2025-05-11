import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';

class SeatBookingPage extends StatefulWidget {
  const SeatBookingPage({super.key});

  @override
  State<SeatBookingPage> createState() => _SeatBookingPageState();
}

class _SeatBookingPageState extends State<SeatBookingPage> {
  String? userType;
  String? selectedRestaurant;
  Map<String, dynamic>? selectedRestaurantData;

  int coupleTable = 0;
  int tableForFour = 0;
  int groupTable = 0;
  int familyTable = 0;

  List<String> restaurantNames = [];
  Map<String, String> restaurantDocIds = {}; // name -> uid

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = userDoc.data();
      if (data != null && data['user_type'] == 'customer') {
        setState(() => userType = 'customer');
        _fetchRestaurants();
      } else {
        setState(() => userType = 'not_customer');
      }
    }
  }

  Future<void> _fetchRestaurants() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('user_type', isEqualTo: 'restaurant')
            .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      restaurantNames.add(data['name']);
      restaurantDocIds[data['name']] = doc.id;
    }
    setState(() {});
  }

  Future<void> _fetchRestaurantData(String name) async {
    final restSnapshot =
        await FirebaseFirestore.instance
            .collection('rest')
            .where('name', isEqualTo: name)
            .get();
    if (restSnapshot.docs.isNotEmpty) {
      selectedRestaurantData = restSnapshot.docs.first.data();
      selectedRestaurant = name;
      setState(() {});
    }
  }

  int _totalSelectedSeats() {
    return coupleTable * 2 +
        tableForFour * 4 +
        groupTable * 8 +
        familyTable * 12;
  }

  bool _canBookTable() {
    if (selectedRestaurantData == null) return false;

    return coupleTable * 2 <= (selectedRestaurantData!['2_people_seat'] ?? 0) &&
        tableForFour * 4 <= (selectedRestaurantData!['4_people_seat'] ?? 0) &&
        groupTable * 8 <= (selectedRestaurantData!['8_people_seat'] ?? 0) &&
        familyTable * 12 <= (selectedRestaurantData!['12_people_seat'] ?? 0) &&
        _totalSelectedSeats() <=
            (selectedRestaurantData!['available seats'] ?? 0);
  }

  Future<void> _bookTable() async {
    if (!_canBookTable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough seats in selected category')),
      );
      return;
    }

    final docId = restaurantDocIds[selectedRestaurant];
    final restRef = FirebaseFirestore.instance.collection('rest').doc(docId);

    await restRef.update({
      '2_people_seat': FieldValue.increment(-coupleTable * 2),
      '4_people_seat': FieldValue.increment(-tableForFour * 4),
      '8_people_seat': FieldValue.increment(-groupTable * 8),
      '12_people_seat': FieldValue.increment(-familyTable * 12),
      'available seats': FieldValue.increment(-_totalSelectedSeats()),
    });

    setState(() {
      coupleTable = 0;
      tableForFour = 0;
      groupTable = 0;
      familyTable = 0;
    });

    await _fetchRestaurantData(selectedRestaurant!);

    // ✅ Add 50 points to the user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('user_points')
          .doc(currentUser.uid)
          .set({'points': FieldValue.increment(50)}, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Table booked successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (userType != 'customer') {
      return const Scaffold(
        body: Center(child: Text('Only customers can access this page')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Booking'),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Restaurant:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedRestaurant,
                    hint: const Text('Choose a restaurant'),
                    items:
                        restaurantNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                    onChanged: (value) => _fetchRestaurantData(value!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedRestaurantData != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Seats: ${selectedRestaurantData!['available seats']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _seatSelector(
                        'Couple Table (2 seats)',
                        coupleTable,
                        (v) => setState(() => coupleTable = v),
                        ((selectedRestaurantData!['2_people_seat'] ?? 0) as num)
                            .toInt(),
                      ),
                      _seatSelector(
                        'Table for Four (4 seats)',
                        tableForFour,
                        (v) => setState(() => tableForFour = v),
                        ((selectedRestaurantData!['4_people_seat'] ?? 0) as num)
                            .toInt(),
                      ),
                      _seatSelector(
                        'Group Table (8 seats)',
                        groupTable,
                        (v) => setState(() => groupTable = v),
                        ((selectedRestaurantData!['8_people_seat'] ?? 0) as num)
                            .toInt(),
                      ),
                      _seatSelector(
                        'Family Table (12 seats)',
                        familyTable,
                        (v) => setState(() => familyTable = v),
                        ((selectedRestaurantData!['12_people_seat'] ?? 0)
                                as num)
                            .toInt(),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Total Seats Selected: ${_totalSelectedSeats()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _bookTable,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            191,
                            160,
                            244,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: const Text('Book Table'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ), //99
      bottomNavigationBar: const BottomNavBar(activeIndex: 1),
    );
  }

  Widget _seatSelector(
    String label,
    int count,
    Function(int) onChanged,
    int maxSeats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (Available: $maxSeats)',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: count > 0 ? () => onChanged(count - 1) : null,
            ),
            Text('$count', style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  count * int.parse(label.replaceAll(RegExp(r'[^0-9]'), '')) <
                          maxSeats
                      ? () => onChanged(count + 1)
                      : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
