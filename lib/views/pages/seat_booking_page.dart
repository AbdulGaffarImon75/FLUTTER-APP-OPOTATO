import 'package:flutter/material.dart';
import '../../controllers/seat_booking_controller.dart';
import 'bottom_nav_bar.dart';

class SeatBookingPage extends StatefulWidget {
  const SeatBookingPage({super.key});
  @override
  State<SeatBookingPage> createState() => _SeatBookingPageState();
}

class _SeatBookingPageState extends State<SeatBookingPage> {
  final _ctrl = SeatBookingController();

  String? _userType;
  Map<String, String> _restaurants = {};
  String? _selectedName;
  String? _selectedDocId;
  Map<String, int>? _availability;

  // Time slots
  final List<String> _timeSlots = const ['2pm', '6pm', '9pm'];
  String? _selectedTime;

  int _c2 = 0, _c4 = 0, _c8 = 0, _c12 = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final type = await _ctrl.fetchCurrentUserType();
    if (!mounted) return;
    setState(() => _userType = type);

    if (type == 'customer') {
      final names = await _ctrl.fetchRestaurantNames();
      if (!mounted) return;
      setState(() => _restaurants = names);
    }
  }

  Future<void> _onRestaurantSelected(String? name) async {
    if (name == null) return;
    final docId = _restaurants[name];
    if (docId == null) return;
    final avail = await _ctrl.fetchAvailability(docId);
    if (!mounted) return;
    setState(() {
      _selectedName = name;
      _selectedDocId = docId;
      _availability = avail;
      _c2 = _c4 = _c8 = _c12 = 0;
      _selectedTime = null; // reset when restaurant changes
    });
  }

  Widget _buildSelector(
    String label,
    int count,
    void Function(int) onChange,
    int maxUnits,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (Available: $maxUnits)'),
        Row(
          children: [
            IconButton(
              onPressed: count > 0 ? () => onChange(count - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$count'),
            IconButton(
              onPressed:
                  (count * int.parse(label.replaceAll(RegExp(r'[^0-9]'), '')) <
                          maxUnits)
                      ? () => onChange(count + 1)
                      : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userType != 'customer') {
      return const Scaffold(
        body: Center(child: Text('Only customers can access this page')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Seat Booking')),
      bottomNavigationBar: const BottomNavBar(activeIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Restaurant:'),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Choose a restaurant'),
              value: _selectedName,
              items:
                  _restaurants.keys
                      .map(
                        (name) =>
                            DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
              onChanged: _onRestaurantSelected,
            ),
            const SizedBox(height: 20),

            if (_availability != null) ...[
              // Time slot selection
              const Text('Select Time Slot:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _timeSlots.map((slot) {
                      final selected = _selectedTime == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedTime = slot),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),

              Text('Available Seats: ${_availability!['available']}'),
              const Divider(),

              _buildSelector(
                'Couple Table (2)',
                _c2,
                (v) => setState(() => _c2 = v),
                _availability!['2']!,
              ),
              _buildSelector(
                'Table for 4',
                _c4,
                (v) => setState(() => _c4 = v),
                _availability!['4']!,
              ),
              _buildSelector(
                'Group Table (8)',
                _c8,
                (v) => setState(() => _c8 = v),
                _availability!['8']!,
              ),
              _buildSelector(
                'Family Table (12)',
                _c12,
                (v) => setState(() => _c12 = v),
                _availability!['12']!,
              ),

              const SizedBox(height: 16),
              Text(
                'Total Selected: ${_ctrl.totalSeatsSelected(_c2, _c4, _c8, _c12)}',
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed:
                    (_selectedTime != null) &&
                            _ctrl.canBook(_c2, _c4, _c8, _c12, _availability!)
                        ? () async {
                          await _ctrl.bookTable(
                            _selectedDocId!,
                            _c2,
                            _c4,
                            _c8,
                            _c12,
                            _selectedTime!, // pass chosen slot
                          );
                          // reload availability
                          _onRestaurantSelected(_selectedName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Table booked for $_selectedTime'),
                            ),
                          );
                        }
                        : null,
                child: const Text('Book Table'),
              ),
              if (_selectedTime == null)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Please select a time slot.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
