import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BkashPaymentPage extends StatelessWidget {
  const BkashPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bKash Payment')),
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
    );
  }
}
