import 'package:flutter/material.dart';
import '/../controllers/offers_controller.dart';
import '/../models/offer_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final _ctrl = OffersController();

  late Future<List<OfferModel>> _offersFuture;
  late Future<Set<String>> _bookmarksFuture;
  late Future<bool> _isCustomerFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = _ctrl.fetchOffers();
    _bookmarksFuture = _ctrl.fetchBookmarkedTitles();
    _isCustomerFuture = _ctrl.isCustomer();
  }

  void _onBookmarkToggle(OfferModel offer) async {
    await _ctrl.toggleBookmark(offer);
    setState(() {
      _bookmarksFuture = _ctrl.fetchBookmarkedTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Offers'), centerTitle: true),
      body: FutureBuilder<List<OfferModel>>(
        future: _offersFuture,
        builder: (context, offerSnap) {
          if (offerSnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final offers = offerSnap.data ?? [];
          if (offers.isEmpty) {
            return const Center(child: Text('No offers available.'));
          }
          return FutureBuilder<bool>(
            future: _isCustomerFuture,
            builder: (context, custSnap) {
              final isCustomer = custSnap.data ?? false;
              return FutureBuilder<Set<String>>(
                future: _bookmarksFuture,
                builder: (context, bmSnap) {
                  final bookmarked = bmSnap.data ?? <String>{};
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offers.length,
                    itemBuilder: (context, i) {
                      final o = offers[i];
                      return _OfferCard(
                        offer: o,
                        isCustomer: isCustomer,
                        isBookmarked: bookmarked.contains(o.title),
                        onBookmarkToggle: () => _onBookmarkToggle(o),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  final bool isCustomer;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const _OfferCard({
    required this.offer,
    required this.isCustomer,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              offer.imageUrl,
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
                      offer.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(offer.price, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            if (isCustomer)
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color.fromARGB(255, 127, 113, 233),
                  ),
                  onPressed: onBookmarkToggle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
