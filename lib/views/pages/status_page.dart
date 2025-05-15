import 'package:flutter/material.dart';
import '../../controllers/payment_controller.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final _ctrl = PaymentController();
  bool _loading = true;
  List<Map<String, dynamic>> _list = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final data = await _ctrl.fetchAllRestaurantsStatus();
    if (!mounted) return;
    setState(() {
      _list = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Payment Status')),
      body:
          _list.isEmpty
              ? const Center(child: Text('No restaurants found'))
              : ListView.builder(
                itemCount: _list.length,
                itemBuilder: (_, i) {
                  final r = _list[i];
                  return ListTile(
                    title: Text(r['name']),
                    subtitle: Text('Status: ${r['payment_status']}'),
                  );
                },
              ),
    );
  }
}
