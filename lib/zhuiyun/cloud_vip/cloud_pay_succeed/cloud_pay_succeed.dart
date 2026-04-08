import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/zhuiyun/cloud_model/CloudVersionStorage.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_login_state.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
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
    unawaited(_refreshVipAndProfile());
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

  Future<void> _refreshVipAndProfile() async {
    // 1) 刷新套餐信息（仪表盘卡片状态）
    await LoginState().refreshVip();

    // 2) 刷新订阅配置文件（支付后可能换订阅链接/节点）
    try {
      final value = await CloudRequest().getSubscribe();
      final data = value.data;
      final baseUrl = CloudVersionStorage.instance.model?.data?.subUrl ??
          CloudRequest().baseUrl;
      final originUrl = data?.subscribeUrl ?? '';
      if (originUrl.isEmpty) return;
      final replacedUrl = originUrl.replaceFirst(
        RegExp(r'^https://[^/]+'),
        baseUrl,
      );
      await _canUpdateProfile(replacedUrl);
    } catch (_) {}
  }

  Future<bool> _canUpdateProfile(String subscribeUrl) async {
    final appController = globalState.appController;
    Profile? currentProfile;
    final currentProfileId = globalState.config.currentProfileId;
    if (currentProfileId != null) {
      for (final p in globalState.config.profiles) {
        if (p.id == currentProfileId) {
          currentProfile = p;
          break;
        }
      }
    }

    if (currentProfile == null) {
      if (subscribeUrl.isEmpty) return false;
      await appController.addProfileFormURL(subscribeUrl);
      if (!globalState.isStart) {
        await appController.applyProfile(silence: true);
      }
      return false;
    }

    final profileToSync = subscribeUrl.isNotEmpty &&
            currentProfile.url != subscribeUrl
        ? currentProfile.copyWith(url: subscribeUrl)
        : currentProfile;
    if (profileToSync.url != currentProfile.url) {
      appController.setProfile(profileToSync);
    }

    final beforeUpdateTime =
        profileToSync.lastUpdateDate?.millisecondsSinceEpoch;
    await appController.updateProfile(profileToSync);

    final updatedProfileId = globalState.config.currentProfileId;
    if (updatedProfileId == null) return false;
    Profile? updatedProfile;
    for (final p in globalState.config.profiles) {
      if (p.id == updatedProfileId) {
        updatedProfile = p;
        break;
      }
    }
    return updatedProfile?.lastUpdateDate?.millisecondsSinceEpoch !=
        beforeUpdateTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            height: 94,
          ),
          CloudThemeAsset(
            Assets.images.iconSucceed.path,
            width: 55,
            height: 55,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '支付成功',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: ()
            async {
              await _refreshVipAndProfile();
              // 2️⃣ 返回上一层或回到根
              Navigator.popUntil(context, (route) => !Navigator.canPop(context));
            },

            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline)),
              child: Text(
                '返回仪表盘',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
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
