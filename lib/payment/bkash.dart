import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> onButtonTap(
  String selected, {
  required BuildContext context,
}) async {
  print('onButtonTap called with: $selected');
  switch (selected) {
    case 'bkash':
      await bkashPayment(context);
      break;
  }
}

Future<void> bkashPayment(BuildContext context) async {
  try {
    print('Starting bKash navigation with context: $context');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('bKash Payment'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: WebViewWidget(
                controller:
                    WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(
                        Uri.parse(
                          'https://pgw-integration.bkash.com/#/merchant/signin',
                        ),
                      ),
              ),
            ),
      ),
    );
    print('bKash page navigation completed');
  } catch (e) {
    print('Error in bKash navigation: $e');
    rethrow;
  }

  // Placeholder for future payment processing when merchant number is available
  /*
  final bkash = Bkash(logResponse: true);
  const double monthly = 500.00;
  try {
    final response = await bkash.pay(
      context: context,
      amount: monthly,
      merchantInvoiceNumber: "6668008",
    );
    print('Payment successful');
    print('Transaction ID: ${response.trxId}');
    print('Payment ID: ${response.paymentId}');
    print('Merchant Invoice: ${response.merchantInvoiceNumber}');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .update({
        'payment_status': 'Paid',
        'last_payment_date': FieldValue.serverTimestamp(),
        'transaction_id': response.trxId,
      });
      print('Firestore updated');
    }
  } on BkashFailure catch (e) {
    print('bKash Error: ${e.message}');
    throw e;
  } catch (e) {
    print('Unexpected error in bKash payment: $e');
    throw e;
  }
  */
}
