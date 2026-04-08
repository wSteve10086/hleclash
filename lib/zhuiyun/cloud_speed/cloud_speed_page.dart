import 'dart:async';
import 'dart:io';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudSpeedPage extends StatefulWidget {
  const CloudSpeedPage({super.key});

  @override
  State<CloudSpeedPage> createState() => _CloudSpeedPageState();
}

class _CloudSpeedPageState extends State<CloudSpeedPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  String _groupNow = '暂无线路';
  String _btnTitle = '立即更新';
  Timer? _timer;
  int _time = 0;
  String _timeText = '00:00:00';
  // Group? _group;

  ///套餐名称
  String _planName = '';

  ///套餐到期时间
  String _expiredAt = '';

  ///套餐使用的百分比
  double _progress = 0;

  ///已使用的流量
  String _transfer = '';

  ///总流量
  String _allTransfer = '';

  @override
  void initState() {
    super.initState();
    getSubscribe();

  }

  void _startTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _time++;
          _timeText = _secondsToTime(_time);
        });
      });
    }
  }

  void _stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
      setState(() {
        _time = 0;
        _timeText = _secondsToTime(_time);
      });
    }
  }

  String _secondsToTime(int seconds) {
    var duration = Duration(seconds: seconds);
    var hh = duration.inHours.toString().padLeft(2, '0');
    var mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    var ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hh:$mm:$ss";
  }

  getSubscribe() {
    CloudRequest().getSubscribe().then((value) {
      var subscribeUrl = value.data?.subscribeUrl ?? '';

      // addProfile(ProfileURL.emptyBean()..url = subscribeUrl);

      setState(() {
        _planName = value.data?.plan?.name ?? '';
        _expiredAt = getExpireAt(value.data?.expiredAt);
        _transfer = getTransfer((value.data?.u ?? 0) + (value.data?.d ?? 0));

        _allTransfer = getTransfer((value.data?.transferEnable ?? 0));
        _progress = ((value.data?.u ?? 0) + (value.data?.d ?? 0)) /
            (value.data?.transferEnable == 0
                ? 1
                : (value.data?.transferEnable ?? 1));
      });
    }).catchError((e) {
      CloudToast.show(CloudRequest.errorMessage(e, fallback: '订阅异常'), context);
    });
  }

  String getTransfer(num t) {
    if (t < 1024) {
      return '${t.toStringAsFixed(2)}KB';
    } else if (t < 1024 * 1024 * 1024) {
      return '${(t / 1024 / 1024).toStringAsFixed(2)}MB';
    } else if (t < 1024 * 1024 * 1024 * 1024) {
      return '${(t / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    } else {
      return '${(t / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)}TB';
    }
  }

  String getExpireAt(num? timestamp) {
    if (timestamp == null) {
      return '不限时长';
    }
    if (timestamp.toInt() * 1000 < DateTime.now().millisecondsSinceEpoch) {
      return '已过期';
    }
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    String formatted = formatter.format(date);
    return formatted;
  }



  Future<void> getProxies() async {
    await Future.delayed(const Duration(seconds: 1));
    // await _proxysController.getProxies();
    // var groups = _proxysController.model.groups;
    // if (groups.isNotEmpty) {
    //   _group = groups.first;
    //   setState(() {
    //     _groupNow = _group!.now;
    //   });
    // }
  }

  // addProfile(ProfileBase profile) {
  //   var loading = Loading.builder();
  //   Asuka.addOverlay(loading);
  //   _controller.addProfile(profile).then((_) {
  //     getProxies();
  //     loading.remove();
  //   }).catchError((e) {
  //     loading.remove();
  //     DioException error = e;
  //     Map<String, dynamic> map = error.response?.data ?? {'message': '订阅异常'};
  //     CloudToast.show(map['message'], context);
  //   });
  // }
  //
 bool get idOpen {
    return true;
    // if (_config.tunIf) {
    //   return _core.tunEnable;
    // } else {
    //   return _config.systemProxy;
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CloudColors.bg,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Container(
            height: 135,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CloudColors.c242738,
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _planName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CloudColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '到期时间: $_expiredAt',
                    style: TextStyle(
                      fontSize: 14,
                      color: CloudColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '已使用 $_transfer / 总流量 $_allTransfer',
                    style: TextStyle(
                      color: CloudColors.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 5,
                  child: Stack(
                    children: [
                      Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width - 72.0,
                        decoration: BoxDecoration(
                          color: CloudColors.border(context).withOpacity(0.45),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Container(
                        height: 5,
                        width: (MediaQuery.of(context).size.width - 72.0) *
                            _progress,
                        decoration: BoxDecoration(
                          color: CloudColors.brandPrimary(context),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Stack(
            children: [
              // Image.asset(
              //   idOpen ? Assets.images.bgStart.path  : Assets.images.bgStop.path,
              //   width: 220,
              //   height: 220,
              // ),
              // if (idOpen)
              //   Positioned(
              //     left: (220 - 55) / 2.0,
              //     top: (220 - 55) / 2.0,
              //     child: AvatarGlow(
              //       glowCount: 5,
              //       startDelay: const Duration(milliseconds: 1000),
              //       glowColor: CloudColors.c3257FF,
              //       glowShape: BoxShape.circle,
              //       animate: idOpen,
              //       curve: Curves.fastOutSlowIn,
              //       child: const SizedBox(
              //         width: 55,
              //         height: 55,
              //       ),
              //     ),
              //   ),
              Positioned(
                left: (220 - 55) / 2.0,
                top: (220 - 55) / 2.0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_expiredAt == '已过期') {
                      CloudToast.show('套餐已过期', context);
                      return;
                    }

                    Future(() {
                      // if (_config.tunIf) {
                      //   if (_core.tunEnable) {
                      //     _stopTimer();
                      //     return _core.closeTun();
                      //   } else {
                      //     return _core.openTun();
                      //   }
                      // } else {
                      //   if (_config.systemProxy) {
                      //     _stopTimer();
                      //     return _config.closeProxy();
                      //   } else {
                      //     return _config.openProxy();
                      //   }
                      // }
                    })
                        .catchError((e) {
                      // if (e is MessageException) {
                      //   // CloudToast.show(e.getMessage(),context);
                      //   _showConfirmDialog(context, e.getMessage());
                      // } else {
                      //   CloudToast.show("发生未知错误", context);
                      // }
                    }).then((value) => setState(() {
                              if (idOpen) {
                                _startTimer();
                              }
                            }));
                  },
                  child: CloudThemeAsset(
                    idOpen ? Assets.images.iconStart.path :Assets.images.iconStop.path  ,
                    width: 55,
                    height: 55,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _timeText,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 40,
                color: CloudColors.textPrimary(context)),
          ),
          // Text(
          //   idOpen ? '已连接' : '未连接',
          //   style: const TextStyle(
          //     fontSize: 14,
          //     color: CloudColors.cA4ADBD,
          //   ),
          // ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _selectMode(),
            child: Text(
              // '代理模式：${_core.clash.mode?.value ?? Mode.Rule.value}',
              '代理模式： ',
              style: TextStyle(
                fontSize: 14,
                color: CloudColors.muted(context),
              ),
            ),
          ),
          const SizedBox(
            height: 47,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {

             // CloudLineRoute().push(context);
              // if (_group != null) {
              //   Modular.to
              //       .pushNamed(
              //         '/cloud_line',
              //         arguments: _group,
              //       )
              //       .then((value) => getProxies());
              // }
            },
            child: Container(
              height: 56,
              width: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CloudColors.c4A4F69,
                    CloudColors.c2D3040,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 23,
                      ),
                      CloudThemeAsset(

                        Assets.images.iconLocation.path,
                        width: 20,
                        height: 20,
                        tintInLight: true,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: 160,
                        child: Text(
                          _groupNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: CloudColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: CloudThemeAsset(
                      Assets.images.iconSelect.path,
                      width: 20,
                      height: 20,
                      tintInLight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _selectMode() {
    // change(Mode? mode, BuildContext context) {
    //   _core.setState(mode: mode);
    //   getProxies();
    //   setState(() {});
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
    //       height: Mode.values.length * 60,
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

  void _showConfirmDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              '温馨提示',
              style: TextStyle(color: Colors.black),
            ),
          ),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('去设置'),
              onPressed: () {
                // Perform some action
                // Modular.to.pushNamed('/cloud_setting');

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
      _time = 0;
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
