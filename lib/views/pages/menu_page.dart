import 'package:flutter/material.dart';
import 'package:O_potato/controllers/menu_page_controller.dart';
import '../../models/menu_model.dart';
import 'bottom_nav_bar.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;
  const MenuPage({super.key, required this.restaurantId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _controller = MenuPageController();

  String? _vendorName;
  String? _userType;
  List<MenuModel> _menus = [];
  bool _loading = true;

  final _titleCtrl = TextEditingController();
  final _segmentCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userType = await _controller.fetchUserType();
    final vendor = await _controller.fetchVendorName(widget.restaurantId);
    List<MenuModel> menus = [];
    if (vendor != null) {
      menus = await _controller.fetchMenus(vendor);
    }
    if (!mounted) return;
    setState(() {
      _userType = userType;
      _vendorName = vendor;
      _menus = menus;
      _loading = false;
    });
  }

  bool get _isOwner =>
      _userType == 'restaurant' &&
      widget.restaurantId == _controller.currentUserId;

  Future<void> _postMenu() async {
    if (_vendorName == null) return;
    await _controller.postMenuItem(
      vendorName: _vendorName!,
      title: _titleCtrl.text,
      segment: _segmentCtrl.text,
      price: _priceCtrl.text,
      imageURL: _imageCtrl.text,
    );
    _titleCtrl.clear();
    _segmentCtrl.clear();
    _priceCtrl.clear();
    _imageCtrl.clear();
    final updated = await _controller.fetchMenus(_vendorName!);
    setState(() => _menus = updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menu posted successfully!')));
  }

  Future<void> _deleteMenu(String id) async {
    await _controller.deleteMenuItem(id);
    final updated = await _controller.fetchMenus(_vendorName!);
    setState(() => _menus = updated);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _segmentCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Group by segment
    final grouped = <String, List<MenuModel>>{};
    for (var item in _menus) {
      grouped.putIfAbsent(item.segment, () => []).add(item);
    }
    final segments = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(_vendorName ?? 'Menu'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOwner) ...[
              const Text(
                'Post Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _segmentCtrl,
                decoration: const InputDecoration(
                  hintText: 'Segment',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  hintText: 'Price (e.g., ৳200)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  hintText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _postMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 191, 160, 244),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text('POST MENU'),
              ),
              const SizedBox(height: 24),
            ],

            // Display each segment
            for (var segment in segments) ...[
              Text(
                segment,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...grouped[segment]!.map(
                (m) => Card(
                  child: ListTile(
                    leading:
                        m.imageURL.isNotEmpty
                            ? Image.network(
                              m.imageURL,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.fastfood),
                    title: Text(m.title),
                    subtitle: Text(m.price),
                    trailing:
                        _isOwner
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenu(m.id),
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
