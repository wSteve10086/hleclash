import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 配置文件页
class CloudSettingPage extends StatefulWidget {
  const CloudSettingPage({super.key});

  @override
  State<CloudSettingPage> createState() => _CloudSettingPageState();
}

class _CloudSettingPageState extends State<CloudSettingPage> {

  String _version = "1.2.0";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = info.version);
      }
    });
  }

  void checkUpdate() async {
    // Request().latest().then((value) {
    //   if (_version == value) {
    //     Asuka.showSnackBar(
    //       const SnackBar(content: Text('当前已经是最新版本！')),
    //     );
    //   } else {
    //     Asuka.showSnackBar(SnackBar(
    //       content: Text("最新版本号为: $value"),
    //       action: SnackBarAction(
    //         label: "前往下载最新版",
    //         onPressed: () =>
    //             launchUrl(Uri.parse("${Constants.sourceUrl}/releases/latest")),
    //       ),
    //     ));
    //   }
    // }).catchError((err) {});
  }

  setValue({
    required String title,
    String? initialValue,
    String? decoration,
    required void Function(String) onOk,
  }) {
    showDialog(
      context: context,
      builder: (cxt) {
        var vController = TextEditingController();
        vController.text = initialValue ?? "";
        return AlertDialog(
          elevation: 7,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: decoration),
                controller: vController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(cxt).pop(),
            ),
            TextButton(
              child: const Text("确认"),
              onPressed: () {
                var value = vController.text;
                if (value.isEmpty) return;
                Navigator.of(cxt).pop();
                onOk(value);
              },
            ),
          ],
        );
      },
    );
  }

  selectMode() {
    // change(Mode? mode, BuildContext context) {
    //   _core.setState(mode: mode);
    //   Navigator.of(context).pop();
    // }
    //
    // Asuka.showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   builder: (cxt) => Material(
    //     borderRadius: const BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //     ),
    //     elevation: 7,
    //     child: SizedBox(
    //       height: Mode.values.length * 50,
    //       child: ListView.builder(
    //         itemCount: Mode.values.length,
    //         itemBuilder: (_, i) {
    //           return ListTile(
    //             contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    //             onTap: () => change(Mode.values[i], cxt),
    //             title: Text(Mode.values[i].value),
    //             trailing: Radio<Mode>(
    //               value: Mode.values[i],
    //               groupValue: _core.clash.mode ?? Mode.Rule,
    //               onChanged: (v) => change(v, cxt),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  selectLogLevel() {
    // change(LogLevel? logLevel, BuildContext context) {
    //   _core.setState(logLevel: logLevel);
    //   Navigator.of(context).pop();
    // }
    //
    // Asuka.showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   builder: (cxt) => Material(
    //     borderRadius: const BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //     ),
    //     elevation: 7,
    //     child: SizedBox(
    //       height: LogLevel.values.length * 50,
    //       child: ListView.builder(
    //         itemCount: LogLevel.values.length,
    //         itemBuilder: (_, i) {
    //           return ListTile(
    //             contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    //             onTap: () => change(LogLevel.values[i], cxt),
    //             title: Text(LogLevel.values[i].value.toUpperCase()),
    //             trailing: Radio<LogLevel>(
    //               value: LogLevel.values[i],
    //               groupValue: _core.clash.logLevel ?? LogLevel.info,
    //               onChanged: (v) => change(v, cxt),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: CloudColors.bg,
      appBar: const CloudAppBar(
        title: '设置',
      ),
      body: Builder(builder: (_) {
        // var redirPort = _core.clash.redirPort ?? 0;
        // var tproxyPort = _core.clash.tproxyPort ?? 0;
        // var mixedPort = _core.clash.mixedPort ?? 0;
        //
        // var allowLan = _core.clash.allowLan ?? false;
        // var ipv6 = _core.clash.ipv6 ?? false;
        // var mode = _core.clash.mode ?? Mode.Rule;
        // var logLevel = _core.clash.logLevel ?? LogLevel.info;
        //
        // var mmdbUrl = _config.clashForMe.mmdbUrl;
        // var delayTestUrl = _config.clashForMe.delayTestUrl;

        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(children: [
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '允许局域网',
                    style: TextStyle(
                      fontSize: 15,
                      color: CloudColors.white,
                    ),
                  ),
                  // Switch(
                  //     value: allowLan,
                  //     onChanged: (v) => _core.setState(allowLan: v))
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'IPv6',
                    style: TextStyle(
                      fontSize: 15,
                      color: CloudColors.white,
                    ),
                  ),
                 // Switch(value: ipv6, onChanged: (v) => _core.setState(ipv6: v))
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => {
                // setValue(
                //   title: "端口",
                //   initialValue: mixedPort.toString(),
                //   onOk: (v) => _core.setState(mixedPort: int.parse(v)),
                // )
              },
              //     (){

              // },
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '端口',
                      style: TextStyle(
                        fontSize: 15,
                        color: CloudColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'mixedPort.toString()',
                          style: const TextStyle(
                              color: CloudColors.white, fontSize: 14),
                        ),
                        Image.asset(
                          'assets/icon_next.png',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => selectMode(),
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '代理模式',
                      style: TextStyle(
                        fontSize: 15,
                        color: CloudColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'mode.value',
                          style: const TextStyle(
                              color: CloudColors.white, fontSize: 14),
                        ),
                        Image.asset(
                          'assets/icon_next.png',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => selectLogLevel(),
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '日志等级',
                      style: TextStyle(
                        fontSize: 15,
                        color: CloudColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                         ' logLevel.value.toUpperCase()',
                          style: const TextStyle(
                              color: CloudColors.white, fontSize: 14),
                        ),
                        Image.asset(
                          'assets/icon_next.png',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              // onTap: () => checkUpdate(),
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '版本号',
                      style: TextStyle(
                        fontSize: 15,
                        color: CloudColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _version,
                          style: const TextStyle(
                              color: CloudColors.white, fontSize: 14),
                        ),
                        Image.asset(
                          'assets/icon_next.png',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                // if (_config.tunIf) {
                //   if (_core.tunEnable) {
                //     return _core.closeTun();
                //   }
                // } else {
                //   if (_config.systemProxy) {
                //     return _config.closeProxy();
                //   }
                // }
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('token', '');
                await prefs.setString('authData', '');
                // Modular.to.navigate("/cloud_login");
              },
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      CloudColors.c3257FF,
                      CloudColors.c24D4F3,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '退出登录',
                    style: TextStyle(
                      color: CloudColors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ]),
        );


      }),
    );
  }
}

///MMDB 更新按钮
class MmdbRefreshButton extends StatefulWidget {
  const MmdbRefreshButton({super.key});

  @override
  State<MmdbRefreshButton> createState() => _MmdbRefreshButtonState();
}

class _MmdbRefreshButtonState extends State<MmdbRefreshButton> {
  // final _config = Modular.get<AppConfig>();
  // final _request = Modular.get<Request>();

  double _value = 0;

  downloadMMDB() {
    if (_value > 0) {
      // if (_value < 1) {
      //   Asuka.showSnackBar(const SnackBar(content: Text("下载中，请稍等")));
      // } else {
      //   Asuka.showSnackBar(
      //       const SnackBar(content: Text("已下载完成，请重启应用以启用新的MMDB")));
      // }
      return;
    }
    // _request
    //     .downFile(
    //   urlPath: _config.clashForMe.mmdbUrl,
    //   savePath: "${Constants.homeDir.path}${Constants.mmdb}",
    //   onReceiveProgress: (received, total) {
    //     setState(() => _value = received / total);
    //   },
    // )
    //     .then((value) {
    //   setState(() => _value = 1);
    //   Asuka.showSnackBar(const SnackBar(content: Text("下载完成，请重启应用以启用新的MMDB")));
    // }).catchError((e) {
    //   setState(() => _value = -1);
    //   Asuka.showSnackBar(SnackBar(content: Text(e.toString())));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "更新MMDB",
      icon: Builder(builder: (_) {
        if (_value == 0) {
          return const Icon(Icons.refresh_rounded);
        } else if (_value == 1) {
          return const Icon(Icons.done_outlined);
        } else if (_value == -1) {
          return const Icon(Icons.error_outlined);
        }
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: _value,
            backgroundColor: Colors.black12,
          ),
        );
      }),
      onPressed: () => downloadMMDB(),
    );
  }
}
