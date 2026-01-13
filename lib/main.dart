import 'dart:async';
import 'dart:io';

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
