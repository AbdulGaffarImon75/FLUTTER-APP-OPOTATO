import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeatBookingPage extends StatefulWidget {
  const SeatBookingPage({super.key});

  @override
  State<SeatBookingPage> createState() => _SeatBookingPageState();
}

class _SeatBookingPageState extends State<SeatBookingPage> {
  Map<String, bool> seats = {};
  List<String> selectedSeats = [];
  bool bookingConfirmed = false; // to block after booking

  @override
  void initState() {
    super.initState();
    fetchSeats();
  }

  Future<void> fetchSeats() async {
    final docSnapshot =
        await FirebaseFirestore.instance
            .collection('res001')
            .doc('seats')
            .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        seats = data.map((key, value) => MapEntry(key, value as bool));
      });
    }
  }

  Future<void> confirmBooking() async {
    if (selectedSeats.isEmpty) return;

    final updates = {for (var seat in selectedSeats) seat: true};

    await FirebaseFirestore.instance
        .collection('res001')
        .doc('seats')
        .update(updates);

    setState(() {
      bookingConfirmed = true;
    });

    fetchSeats();
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final seatList = seats.entries.toList();
    List<Widget> tableGroups = [];
    int index = 0;
    int tableNumber = 1;

    while (index < seatList.length) {
      List<Widget> topSeats = [];
      List<Widget> bottomSeats = [];
      List<String> currentTableSeats = [];

      // 2 seats on top
      for (int i = 0; i < 2 && index < seatList.length; i++) {
        topSeats.add(
          buildSeatWidget(seatList[index].key, seatList[index].value),
        );
        currentTableSeats.add(seatList[index].key);
        index++;
      }

      // 2 seats at bottom
      for (int i = 0; i < 2 && index < seatList.length; i++) {
        bottomSeats.add(
          buildSeatWidget(seatList[index].key, seatList[index].value),
        );
        currentTableSeats.add(seatList[index].key);
        index++;
      }

      tableGroups.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: topSeats,
            ),
            const SizedBox(height: 6),
            buildFancyTableWidget(tableNumber, currentTableSeats),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: bottomSeats,
            ),
          ],
        ),
      );

      tableNumber++;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fancy Seat Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
              tableGroups
                  .map(
                    (group) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: group),
                    ),
                  )
                  .toList(),
        ),
      ),
      bottomNavigationBar:
          selectedSeats.isNotEmpty && !bookingConfirmed
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: confirmBooking,
                  child: const Text('Confirm Table Booking'),
                ),
              )
              : null,
    );
  }

  Widget buildSeatWidget(String seatName, bool isBooked) {
    final isSelected = selectedSeats.contains(seatName);

    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            isBooked ? Colors.red : (isSelected ? Colors.blue : Colors.green),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.event_seat, color: Colors.white, size: 24),
      ),
    );
  }

  Widget buildFancyTableWidget(int tableNumber, List<String> seatNames) {
    bool allSeatsBooked = seatNames.every((seat) => seats[seat] == true);
    bool anySeatSelected = seatNames.any(
      (seat) => selectedSeats.contains(seat),
    );

    return GestureDetector(
      onTap: () {
        if (bookingConfirmed) return; // prevent multiple booking
        if (allSeatsBooked) return; // table already booked
        if (selectedSeats.isNotEmpty) return; // only allow selecting one table

        setState(() {
          selectedSeats = seatNames;
        });
      },
      child: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color:
              allSeatsBooked
                  ? Colors.grey
                  : (anySeatSelected ? Colors.blue : Colors.brown.shade600),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Table $tableNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
