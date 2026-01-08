import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class CloudCustomerServicePage extends StatefulWidget {
  const CloudCustomerServicePage({super.key});

  @override
  State<CloudCustomerServicePage> createState() =>
      _CloudCustomerServicePageState();
}

class _CloudCustomerServicePageState extends State<CloudCustomerServicePage> {
  late WebViewController _controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initMobile();
  }

  void _initMobile() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CloudColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://go.crisp.chat/chat/embed/?website_id=45c82007-8e52-44e6-8ded-31db17a83c4f'));
    // ..loadFlutterAsset('assets/customer_service.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloudColors.bg,
      appBar: const CloudAppBar(title: '客服'),
      body: WebViewWidget(controller: _controller),
    );
  }
}
