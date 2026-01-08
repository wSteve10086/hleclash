import 'dart:io';

import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay_succeed/cloud_pay_succeed.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CloudPayPage extends StatefulWidget {
  const CloudPayPage(this.payUrl, {super.key});
  final String payUrl;
  @override
  State<CloudPayPage> createState() => _CloudPayPageState();
}

class _CloudPayPageState extends State<CloudPayPage> {
  late WebViewController _controller;
  double _progress = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initMobile(widget.payUrl);
  }

  void _initMobile(String payUrl) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _progress = 1.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            final curUrl = error.url ?? '';
            if (error.errorType == WebResourceErrorType.unsupportedScheme) {
              if (curUrl.startsWith('alipays') ||
                  curUrl.startsWith('alipay://')) {
                launchUrl(Uri.parse(curUrl));
                return;
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (Platform.isAndroid) {
              if (request.url.startsWith('https://wx.tenpay.com')) {
                _controller.loadRequest(Uri.parse(request.url),
                    headers: {'Referer': 'H5 Referer'});
                return NavigationDecision.prevent;
              }
              if (request.url.startsWith('weixin://')) {
                launchUrl(Uri.parse(request.url));
                return NavigationDecision.prevent;
              }
              if (request.url.startsWith('alipays') ||
                  request.url.startsWith('alipay://')) {
                launchUrl(Uri.parse(request.url));
                return NavigationDecision.prevent;
              }
            }

            if (request.url.contains('trade_status=TRADE_SUCCES')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CloudPaySucceedPage(),
                ),
              );
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(payUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('支付'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 5,
            child: Stack(
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CloudColors.white,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Container(
                  height: 5,
                  width: MediaQuery.of(context).size.width * _progress,
                  decoration: BoxDecoration(
                    color: CloudColors.c2D79FB,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
