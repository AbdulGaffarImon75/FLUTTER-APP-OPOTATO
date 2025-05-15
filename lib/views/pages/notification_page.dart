import 'package:flutter/material.dart';
import '../../controllers/notification_controller.dart';
import '../../models/customer_notification_model.dart';
import 'bottom_nav_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _ctrl = NotificationController();
  List<CustomerNotification> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _ctrl.fetchCustomerNotifications();
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
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 191, 160, 244),
      ),
      bottomNavigationBar: const BottomNavBar(activeIndex: 3),
      body:
          _notes.isEmpty
              ? const Center(child: Text('No new notifications'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (ctx, i) {
                  final n = _notes[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            n.profileImageUrl.isNotEmpty
                                ? NetworkImage(n.profileImageUrl)
                                : null,
                        child:
                            n.profileImageUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(n.name),
                      subtitle: Text('${n.postedBy} · ${n.price}'),
                      trailing:
                          n.imageUrl.isNotEmpty
                              ? Image.network(
                                n.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                              )
                              : null,
                    ),
                  );
                },
              ),
    );
  }
}
