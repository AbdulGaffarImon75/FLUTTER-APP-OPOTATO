import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:O_potato/controllers/revieww_controller.dart';
import 'package:O_potato/models/review_model.dart';
import 'bottom_nav_bar.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;
  const ReviewPage({super.key, required this.restaurantId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _ctrl = ReviewController();
  final _textCtrl = TextEditingController();

  bool _isCustomer = false;
  String? _custName, _custImage;
  String? _restName, _restImage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final isCust = await _ctrl.isCustomer();
    final userInfo = await _ctrl.fetchUserInfo();
    final restInfo = await _ctrl.fetchRestaurantInfo(widget.restaurantId);
    if (!mounted) return;
    setState(() {
      _isCustomer = isCust;
      _custName = userInfo['name'];
      _custImage = userInfo['image'];
      _restName = restInfo['name'];
      _restImage = restInfo['image'];
    });
  }

  String _formatDate(DateTime d) {
    final day = d.day;
    String suf;
    if (day >= 11 && day <= 13)
      suf = 'th';
    else if (day % 10 == 1)
      suf = 'st';
    else if (day % 10 == 2)
      suf = 'nd';
    else if (day % 10 == 3)
      suf = 'rd';
    else
      suf = 'th';
    return '$day$suf ${DateFormat('MMMM yyyy').format(d)}';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_restName ?? 'Reviews'),
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: Column(
        children: [
          if (_restImage != null && _restImage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _restImage!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _restName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<ReviewModel>>(
              stream: _ctrl.reviewsStream(widget.restaurantId),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) {
                  return const Center(child: Text('No reviews yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) {
                    final r = reviews[i];
                    return Card(
                      color: const Color.fromARGB(255, 233, 185, 244),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              (r.userImage ?? '').isNotEmpty
                                  ? NetworkImage(r.userImage!)
                                  : null,
                          child:
                              (r.userImage ?? '').isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                        title: Text(r.userName),
                        subtitle: Text(r.text),
                        trailing: Text(
                          r.timestamp != null ? _formatDate(r.timestamp!) : '',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isCustomer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write your review...',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _ctrl.postReview(widget.restaurantId, _textCtrl.text);
                        _textCtrl.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          191,
                          160,
                          244,
                        ),
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text('Post Review'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
