import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/restaurant_dashboard_controller.dart';
import '../../models/offer_model.dart';
import '../../models/combo_model.dart';
import '../../models/seat_status_model.dart';
import 'bottom_nav_bar.dart';

class RestaurantDashboardPage extends StatefulWidget {
  const RestaurantDashboardPage({super.key});
  @override
  State<RestaurantDashboardPage> createState() =>
      _RestaurantDashboardPageState();
}

class _RestaurantDashboardPageState extends State<RestaurantDashboardPage> {
  final _ctrl = RestaurantDashboardController();
  DashboardData? _data;
  bool _loading = true;

  final _offerName = TextEditingController();
  final _offerPrice = TextEditingController();
  final _offerImage = TextEditingController();
  final _comboTitle = TextEditingController();
  final _comboPrice = TextEditingController();
  final _comboImage = TextEditingController();
  final _add2 = TextEditingController();
  final _add4 = TextEditingController();
  final _add8 = TextEditingController();
  final _add12 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _ctrl.loadDashboardData();
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext c) {
    if (_loading || _data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final d = _data!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    d.profileImageUrl.isNotEmpty
                        ? NetworkImage(d.profileImageUrl)
                        : null,
                child:
                    d.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                d.restaurantName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Post Offer
            const Text(
              'Post Offer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField('Offer Name', _offerName),
            const SizedBox(height: 8),
            _buildTextField('Price', _offerPrice, number: true),
            const SizedBox(height: 8),
            _buildTextField('Image URL', _offerImage),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ctrl.postOffer(
                    _offerName.text,
                    _offerPrice.text,
                    _offerImage.text,
                    d,
                  );
                  _offerName.clear();
                  _offerPrice.clear();
                  _offerImage.clear();
                  await _load();
                } catch (e) {
                  _showError('Failed to post offer');
                }
              },
              child: const Text('POST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 191, 160, 244),
              ),
            ),

            const SizedBox(height: 24),
            // Post Combo
            const Text(
              'Post Combo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField('Combo Title', _comboTitle),
            const SizedBox(height: 8),
            _buildTextField('Price', _comboPrice, number: true),
            const SizedBox(height: 8),
            _buildTextField('Image URL', _comboImage),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ctrl.postCombo(
                    _comboTitle.text,
                    _comboPrice.text,
                    _comboImage.text,
                    d,
                  );
                  _comboTitle.clear();
                  _comboPrice.clear();
                  _comboImage.clear();
                  await _load();
                } catch (e) {
                  _showError('Failed to post combo');
                }
              },
              child: const Text('POST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 191, 160, 244),
              ),
            ),

            const SizedBox(height: 24),
            // Update Seats
            const Text(
              'Update Seat Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField('Add 2-person seats', _add2, number: true),
            const SizedBox(height: 8),
            _buildTextField('Add 4-person seats', _add4, number: true),
            const SizedBox(height: 8),
            _buildTextField('Add 8-person seats', _add8, number: true),
            const SizedBox(height: 8),
            _buildTextField('Add 12-person seats', _add12, number: true),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ctrl.updateSeats(
                    add2: int.tryParse(_add2.text) ?? 0,
                    add4: int.tryParse(_add4.text) ?? 0,
                    add8: int.tryParse(_add8.text) ?? 0,
                    add12: int.tryParse(_add12.text) ?? 0,
                  );
                  _add2.clear();
                  _add4.clear();
                  _add8.clear();
                  _add12.clear();
                  await _load();
                } catch (e) {
                  _showError('Over capacity!');
                }
              },
              child: const Text('UPDATE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 191, 160, 244),
              ),
            ),

            const SizedBox(height: 24),
            // Seat summary
            Text(
              'Available: ${d.seatStatus.available} / Total: ${d.seatStatus.total}',
            ),
            Text('2-seats: ${d.seatStatus.two}, 4-seats: ${d.seatStatus.four}'),
            Text(
              '8-seats: ${d.seatStatus.eight}, 12-seats: ${d.seatStatus.twelve}',
            ),

            const SizedBox(height: 24),
            // Offers list
            const Text(
              'Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...d.offers.map(
              (o) => ListTile(
                title: Text(o.title),
                subtitle: Text(
                  DateFormat('MMM d, h:mm a').format(o.timestamp!),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _ctrl.deleteOffer(o.id);
                    await _load();
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Combos list
            const Text(
              'Combos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...d.combos.map(
              (c) => ListTile(
                title: Text(c.title),
                subtitle: Text(
                  DateFormat('MMM d, h:mm a').format(c.timestamp!),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _ctrl.deleteCombo(c.id);
                    await _load();
                  },
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool number = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
