import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';

class FlClashHttpOverrides extends HttpOverrides {
  static String handleFindProxy(Uri url) {
    final host = url.host.toLowerCase();
    if (host == localhost || host == 'localhost' || host == '::1') {
      return 'DIRECT';
    }
    final port = globalState.config.patchClashConfig.mixedPort;
    final isStart = globalState.appState.runTime != null;
    commonPrint.log('find $url proxy:$isStart');
    if (isStart) {
      // Use IPv4 loopback: on some Windows setups "localhost" resolves to ::1 first
      // while the core listens on 127.0.0.1 only, causing intermittent failures.
      return 'PROXY 127.0.0.1:$port';
    }
    // When the core is off, do not force DIRECT: browsers still use HTTP(S)_PROXY from
    // the environment (common on managed Windows). Without this, login/API calls fail
    // while the same URL works in Edge/Chrome.
    final fromEnv = HttpClient.findProxyFromEnvironment(url);
    if (fromEnv != 'DIRECT' && fromEnv.trim().isNotEmpty) {
      return fromEnv;
    }
    return 'DIRECT';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, _, _) => true;
    client.findProxy = handleFindProxy;
    return client;
  }
}
