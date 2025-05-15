import 'package:flutter/material.dart';
import '../../controllers/payment_controller.dart';
import 'status_page.dart';
import 'bkash_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _ctrl = PaymentController();
  String? _userType;
  Map<String, dynamic>? _restData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final type = await _ctrl.getUserType();
    if (!mounted) return;
    setState(() => _userType = type);

    if (type == 'restaurant') {
      final uid = _ctrl.currentUserId!;
      final data = await _ctrl.ensureAndFetchRestaurantDoc(uid);
      if (!mounted) return;
      setState(() {
        _restData = data;
        _loading = false;
      });
    } else if (type == 'admin') {
      // immediately navigate to status page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatusPage()),
        );
      });
    } else {
      // not authorized
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userType != 'restaurant') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final status = _restData!['payment_status'] as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Status: $status',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (status != 'Paid')
              ElevatedButton(
                onPressed: () async {
                  // push to bKash flow
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BkashPaymentPage()),
                  );
                  // refresh after return
                  final uid = _ctrl.currentUserId!;
                  final data = await _ctrl.ensureAndFetchRestaurantDoc(uid);
                  if (!mounted) return;
                  setState(() => _restData = data);
                },
                child: const Text('Pay with bKash'),
              ),
          ],
        ),
      ),
    );
  }
}
