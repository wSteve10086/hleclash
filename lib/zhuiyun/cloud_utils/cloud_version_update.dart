import 'dart:io';

import 'package:fl_clash/state.dart';
import 'package:fl_clash/zhuiyun/cloud_model/CloudVersionStorage.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_version_model.dart';
import 'package:fl_clash/zhuiyun/cloud_update/cloud_download_webpage.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 全局版本更新：[Data.forcedFlag] == 1 可选更新，== 2 强制更新（不可关闭、必须点更新）。
class CloudVersionUpdate {
  CloudVersionUpdate._();

  static bool _dialogVisible = false;

  /// 远端版本是否高于本地（语义化版本比较，忽略前缀 `v`）。
  static bool isRemoteNewer(String localVersion, String? remoteRaw) {
    if (remoteRaw == null || remoteRaw.isEmpty) return false;
    final remote = remoteRaw.trim().replaceFirst(RegExp(r'^v'), '');
    final current = localVersion.trim().replaceFirst(RegExp(r'^v'), '');
    try {
      return _compareParts(current, remote) < 0;
    } catch (_) {
      return false;
    }
  }

  static int _compareParts(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }

  static String platformDownloadUrl(Data? data) {
    if (data == null) return '';
    if (Platform.isAndroid) return data.updateAddress_android ?? '';
    if (Platform.isIOS) return data.updateAddress_ios ?? '';
    if (Platform.isMacOS) return data.updateAddress_mac ?? '';
    if (Platform.isWindows) return data.updateAddress_windows ?? '';
    return data.updateAddress ?? '';
  }

  /// [forcedFlag] 1 可选更新，2 强制更新；仅当远端版本更高时返回非 null。
  static CloudVersionUpdateOffer? evaluateOffer(
    Data? data,
    String localVersion,
  ) {
    if (data == null) return null;
    final flag = data.forcedFlag?.toInt();
    if (flag != 1 && flag != 2) return null;
    if (!isRemoteNewer(localVersion, data.version)) return null;
    return CloudVersionUpdateOffer(isForce: flag == 2, data: data);
  }

  /// 启动后自动检查（全平台一次）；已有弹窗则跳过。
  static Future<void> checkAndPrompt({BuildContext? context}) async {
    await _prompt(context: context, userInitiated: false);
  }

  /// 用户点击「检查更新」：无新版本时 Toast。
  static Future<void> checkFromUser(BuildContext context) async {
    await _prompt(context: context, userInitiated: true);
  }

  static Future<void> _prompt({
    BuildContext? context,
    required bool userInitiated,
  }) async {
    final ctx = context ?? globalState.navigatorKey.currentContext;
    if (ctx == null) return;
    if (!userInitiated && _dialogVisible) return;

    final data = CloudVersionStorage.instance.model?.data;
    final packageInfo = await PackageInfo.fromPlatform();
    final local = packageInfo.version;
    final offer = evaluateOffer(data, local);

    if (offer == null) {
      final after = context ?? globalState.navigatorKey.currentContext;
      if (userInitiated && after != null && after.mounted) {
        CloudToast.show('已是最新版本', after);
      }
      return;
    }

    final dialogContext = context ?? globalState.navigatorKey.currentContext;
    if (dialogContext == null || !dialogContext.mounted) return;
    await _showDialog(
      dialogContext,
      data: offer.data,
      localVersion: local,
      isForce: offer.isForce,
    );
  }

  static Future<void> _showDialog(
    BuildContext context, {
    required Data data,
    required String localVersion,
    required bool isForce,
  }) async {
    if (!context.mounted) return;
    _dialogVisible = true;
    final vList = data.versionIntroduction?.split('\n') ?? [];
    final downloadUrl = platformDownloadUrl(data);
    final remoteVersion =
        data.version?.trim().replaceFirst(RegExp(r'^v'), '') ?? localVersion;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isForce,
        useRootNavigator: true,
        builder: (c) {
          return PopScope(
            canPop: !isForce,
            child: Center(
              child: Container(
                height: 310,
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [CloudColors.c40455D, CloudColors.c242738],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isForce ? '版本更新' : '有新版本啦',
                      style: const TextStyle(
                        fontSize: 21,
                        color: CloudColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '最新版本：$remoteVersion  当前版本：$localVersion',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CloudColors.cA4ADBD,
                      ),
                    ),
                    Container(
                      height: 160,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vList
                              .map(
                                (line) => Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CloudColors.white,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    if (!isForce)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => Navigator.of(c).pop(),
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: CloudColors.cA4ADBD,
                                  ),
                                ),
                                child: const Text(
                                  '稍后再说',
                                  style: TextStyle(
                                    color: CloudColors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _goUpdate(
                                context: context,
                                dialogContext: c,
                                remoteDisplayVersion: remoteVersion,
                                vList: vList,
                                downloadUrl: downloadUrl,
                              ),
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      CloudColors.c63483D,
                                      CloudColors.cBA987A,
                                    ],
                                  ),
                                ),
                                child: const Text(
                                  '立即更新',
                                  style: TextStyle(
                                    color: CloudColors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _goUpdate(
                          context: context,
                          dialogContext: c,
                          remoteDisplayVersion: remoteVersion,
                          vList: vList,
                          downloadUrl: downloadUrl,
                        ),
                        child: Container(
                          height: 44,
                          width: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                CloudColors.c63483D,
                                CloudColors.cBA987A,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '立即更新',
                              style: TextStyle(
                                color: CloudColors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _dialogVisible = false;
    }
  }

  static Future<void> _goUpdate({
    required BuildContext context,
    required BuildContext dialogContext,
    required String remoteDisplayVersion,
    required List<String> vList,
    required String downloadUrl,
  }) async {
    if (downloadUrl.isEmpty) {
      CloudToast.show('更新地址异常，请联系客服处理', context);
      return;
    }
    Navigator.of(dialogContext).pop();
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => UpdateDownloadPage(
          version: remoteDisplayVersion,
          updateLogs: vList,
          downloadUrl: downloadUrl,
        ),
      ),
    );
  }
}

class CloudVersionUpdateOffer {
  final bool isForce;
  final Data data;

  CloudVersionUpdateOffer({required this.isForce, required this.data});
}
