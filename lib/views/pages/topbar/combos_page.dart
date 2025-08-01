// views/pages/combos_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/../controllers/combos_controller.dart';
import '/../models/combo_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';

class CombosPage extends StatefulWidget {
  const CombosPage({super.key});

  @override
  State<CombosPage> createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  final CombosController _controller = CombosController();
  List<ComboModel> _combos = [];
  Set<String> _bookmarked = {};
  bool _isCustomer = false;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    if (_userId != null) {
      _isCustomer = await _controller.isCustomer(_userId!);
      _bookmarked = await _controller.fetchBookmarkedTitles(_userId!);
    }
    _combos = await _controller.fetchCombos();
    setState(() => _isLoading = false);
  }

  Future<void> _onBookmarkTap(ComboModel combo) async {
    if (_userId == null) return;
    final isBookmarked = _bookmarked.contains(combo.title);
    await _controller.toggleBookmark(_userId!, combo, isBookmarked);
    _bookmarked = await _controller.fetchBookmarkedTitles(_userId!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Combos'), centerTitle: true),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body:
          _combos.isEmpty
              ? const Center(child: Text('No combos available.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _combos.length,
                itemBuilder: (ctx, i) {
                  final combo = _combos[i];
                  final bookmarked = _bookmarked.contains(combo.title);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            combo.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 40),
                                ),
                          ),
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              color: Colors.white70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    combo.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${combo.vendor} · ${combo.price}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isCustomer)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: IconButton(
                                icon: Icon(
                                  bookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: const Color.fromARGB(
                                    255,
                                    127,
                                    113,
                                    233,
                                  ),
                                ),
                                onPressed: () => _onBookmarkTap(combo),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
