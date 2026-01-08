import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_login_state.dart';
import 'package:flutter/material.dart';

class CloudPaySucceedPage extends StatefulWidget {
  const CloudPaySucceedPage({super.key});

  @override
  State<CloudPaySucceedPage> createState() => _CloudPaySucceedPageState();
}

class _CloudPaySucceedPageState extends State<CloudPaySucceedPage> {
  @override
  void initState() {
    super.initState();
    LoginState().vip = VipState.normal;
    LoginState().loadVip();

    if (Platform.isMacOS || Platform.isAndroid) {
      final eItem = AnalyticsEventItem(
        itemId: "SKU_888",
        itemName: "套餐",
        itemCategory: "VPN",
        itemVariant: "black",
        itemBrand: "ZhuiYun",
        price: 10,
        quantity: 1,
      );
      final DateTime currentTime = DateTime.now();
      final int timestamp = currentTime.millisecondsSinceEpoch;
      FirebaseAnalytics.instance.logPurchase(
        transactionId: "id_$timestamp",
        affiliation: "Google Store",
        currency: 'CNY',
        value: 10,
        shipping: 0.00,
        tax: 0.00,
        coupon: "SUMMER_FUN",
        items: [eItem],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            height: 94,
          ),
          Image.asset(
            Assets.images.iconSucceed.path,
            width: 55,
            height: 55,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            '支付成功',
            style: TextStyle(
              color: CloudColors.c020202,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              LoginState().vip = VipState.normal;
              LoginState().loadVip();
              Navigator.popUntil(context, (route) => Navigator.canPop(context));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CloudColors.c020202)),
              child: const Text(
                '返回仪表盘',
                style: TextStyle(
                  color: CloudColors.c020202,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
