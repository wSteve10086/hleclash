import 'dart:async';
import 'dart:io';
import 'dart:io' as io;

import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_login_state.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application.dart';
import 'common/common.dart';
import 'core/controller.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_clash/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  repairNetwork();

  /// 获取baseurl
  final cloudRequest = CloudRequest();
  final versionFuture = system.version;
  final refreshBaseUrlFuture = cloudRequest.refreshBaseUrl();
  final initLoginFuture = initLoginState();

  await Future.wait([
    versionFuture,
    refreshBaseUrlFuture,
    initLoginFuture,
  ]);

  final version = await versionFuture;
  await globalState.initApp(version);
  HttpOverrides.global = FlClashHttpOverrides();
  if (Platform.isAndroid || Platform.isMacOS) {
    Future(() async {
      await initFirebaseOnce();
      FirebaseAnalytics.instance;
    });
  }

  runApp(ProviderScope(child: const Application()));
}

Future<void> initFirebaseOnce() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase initialized');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      debugPrint('🔥 Firebase already initialized (native)');
    } else {
      rethrow;
    }
  }
}


/// 清除垃圾代理
Future<bool> repairNetwork() async {
  try {
    if (Platform.isWindows) {
      return await repairWindows();
    } else if (Platform.isMacOS) {
      return await repairMacNetwork();
    } else {
      print("当前平台不支持网络修复");
      return false;
    }
  } catch (e) {
    print("repairNetwork 异常: $e");
    return false;
  }
}

Future<bool> repairWindows() async {

  try {
    print("===== 开始修复网络 =====");

    // 1️⃣ 重置 WinHTTP 代理
    print("执行: netsh winhttp reset proxy");
    final winhttp = await io.Process.run(
      'cmd',
      ['/c', 'netsh winhttp reset proxy'],
      runInShell: true,
    );

    print("stdout: ${winhttp.stdout}");
    print("stderr: ${winhttp.stderr}");
    print("exitCode: ${winhttp.exitCode}");

    // 2️⃣ 关闭浏览器系统代理
    print("关闭系统代理 ProxyEnable");
    final reg = await io.Process.run(
      'cmd',
      [
        '/c',
        'reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" '
            '/v ProxyEnable /t REG_DWORD /d 0 /f'
      ],
      runInShell: true,
    );

    print("stdout: ${reg.stdout}");
    print("stderr: ${reg.stderr}");
    print("exitCode: ${reg.exitCode}");

    // 3️⃣ 清除 DNS
    print("执行: ipconfig /flushdns");
    final dns = await io.Process.run(
      'cmd',
      ['/c', 'ipconfig /flushdns'],
      runInShell: true,
    );

    print("stdout: ${dns.stdout}");
    print("stderr: ${dns.stderr}");
    print("exitCode: ${dns.exitCode}");

    print("===== 网络修复完成 =====");

    return true;
  } catch (e) {
    print("❌ 修复网络异常: $e");
    return false;
  }
}

Future<bool> repairMacNetwork() async {
  if (!io.Platform.isMacOS) {
    print("当前不是 macOS，跳过");
    return false;
  }

  try {
    print("===== 开始 macOS 网络修复 =====");

    // 1️⃣ 获取当前网络服务名称（通常是 Wi-Fi）
    final servicesResult = await io.Process.run(
      'networksetup',
      ['-listallnetworkservices'],
    );

    final services = servicesResult.stdout
        .toString()
        .split('\n')
        .where((s) =>
    s.trim().isNotEmpty &&
        !s.contains('*')) // 排除禁用项
        .toList();

    print("检测到网络服务: $services");

    for (var service in services) {
      print("关闭代理: $service");

      await io.Process.run(
        'networksetup',
        ['-setwebproxystate', service, 'off'],
      );

      await io.Process.run(
        'networksetup',
        ['-setsecurewebproxystate', service, 'off'],
      );

      await io.Process.run(
        'networksetup',
        ['-setsocksfirewallproxystate', service, 'off'],
      );
    }

    // 2️⃣ 刷新 DNS
    print("刷新 DNS...");
    await io.Process.run('dscacheutil', ['-flushcache']);
    await io.Process.run('killall', ['-HUP', 'mDNSResponder']);

    print("===== macOS 网络修复完成 =====");
    return true;
  } catch (e) {
    print("❌ macOS 网络修复异常: $e");
    return false;
  }
}

Future<void> initLoginState() async {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('vip_list', '');
    prefs.setString('invite', '');
    prefs.setString('expired', '');
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final authData = prefs.getString('authData') ?? '';

  if (token.isEmpty || authData.isEmpty) {
    LoginState().value = false;
  } else {
    LoginState().value = true;
  }
}


@pragma('vm:entry-point')
Future<void> _service(List<String> flags) async {
  WidgetsFlutterBinding.ensureInitialized();
  globalState.isService = true;
  await globalState.init();
  await coreController.preload();
  tile?.addListener(
    _TileListenerWithService(
      onStop: () async {
        await app?.tip(appLocalizations.stopVpn);
        await globalState.handleStop();
      },
    ),
  );
  app?.tip(appLocalizations.startVpn);
  final version = await system.version;
  await coreController.init(version);
  final clashConfig = globalState.config.patchClashConfig.copyWith.tun(
    enable: false,
  );
  final setupState = globalState.getSetupState(
    globalState.config.currentProfileId,
  );
  globalState.setupConfig(
    setupState: setupState,
    patchConfig: clashConfig,
    preloadInvoke: () {
      globalState.handleStart();
    },
  );
}

@immutable
class _TileListenerWithService with TileListener {
  final Function() _onStop;

  const _TileListenerWithService({required Function() onStop})
      : _onStop = onStop;

  @override
  void onStop() {
    _onStop();
  }
}
