import 'package:flutter/material.dart';
import '../../controllers/restaurant_notification_controller.dart';
import '../../models/restaurant_notification_model.dart';
import 'bottom_nav_bar.dart';

class RestaurantNotificationPage extends StatefulWidget {
  const RestaurantNotificationPage({super.key});
  @override
  State<RestaurantNotificationPage> createState() =>
      _RestaurantNotificationPageState();
}

class _RestaurantNotificationPageState
    extends State<RestaurantNotificationPage> {
  final _ctrl = RestaurantNotificationController();
  List<RestaurantNotification> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _ctrl.fetchNotifications();
    if (!mounted) return;
    setState(() {
      _notes = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      bottomNavigationBar: const BottomNavBar(activeIndex: 3),
      body:
          _notes.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (ctx, i) {
                  final n = _notes[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(n.message),
                      subtitle: Text(
                        n.timestamp?.toString() ?? 'Time unknown',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
