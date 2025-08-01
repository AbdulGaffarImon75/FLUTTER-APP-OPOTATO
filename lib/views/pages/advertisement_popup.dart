import 'package:flutter/material.dart';
import '../../controllers/advertisement_controller.dart';

class AdvertisementPopup extends StatefulWidget {
  const AdvertisementPopup({super.key});

  @override
  State<AdvertisementPopup> createState() => _AdvertisementPopupState();
}

class _AdvertisementPopupState extends State<AdvertisementPopup> {
  final AdvertisementController _ctrl = AdvertisementController();
  bool _isCustomer = false;
  bool _visible = false;
  bool _showClose = false;
  List<Map<String, dynamic>> _items = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPopup();
  }

  Future<void> _initPopup() async {
    final cust = await _ctrl.isCustomer();
    if (!cust) return;
    setState(() => _isCustomer = true);

    final items = await _ctrl.fetchUnfollowedItems();
    if (items.isEmpty) return;
    setState(() => _items = items);

    _showPopup();
  }

  void _showPopup() {
    setState(() {
      _visible = true;
      _showClose = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showClose = true);
    });
  }

  void _closePopup() {
    setState(() => _visible = false);
    _currentIndex++;
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _items.isNotEmpty) _showPopup();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCustomer || !_visible || _items.isEmpty) {
      return const SizedBox.shrink();
    }
    final item = _items[_currentIndex % _items.length];
    final imageUrl = item['imageURL'] ?? '';
    final title = item['title'] ?? 'Special Deal';
    final price = item['price'] ?? '';
    final poster = item['poster'] ?? 'Vendor';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.455,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stack) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$title - $price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Offered by $poster',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Take a look",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "T&Cs apply.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (_showClose)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _closePopup,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
