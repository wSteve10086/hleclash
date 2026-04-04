import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CloudMinePage extends StatefulWidget {
  const CloudMinePage({super.key});

  @override
  State<CloudMinePage> createState() => _CloudMinePageState();
}

class _CloudMinePageState extends State<CloudMinePage>
    with AutomaticKeepAliveClientMixin {
  final _list = ['我的订单', '邀请返利', '设置'];
  String _email = '';
  // final _cloudRequest = Modular.get<CloudRequest>();

  ///套餐到期时间
  String _expiredAt = '';
  @override
  void initState() {
    super.initState();
    _getSubscribe();
    // analytics();
  }

  // Future<void> analytics() async {
  //   if (Platform.isIOS || Platform.isAndroid) {
  //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //     var version = packageInfo.version;
  //     FirebaseAnalytics.instance
  //         .setDefaultEventParameters({'version': version});
  //   }
  // }

  _getSubscribe() {
    CloudRequest().getSubscribe().then((value) {
      setState(() {
        _expiredAt = getExpireAt(value.data?.expiredAt);
        _email = getEmail(value.data?.email ?? '');
      });
    }).catchError((e) {
      DioException error = e;
      var map = error.response?.data ?? {'message': '订阅异常'};
      CloudToast.show(map['message'].toString(), context);
    });
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

  String getEmail(String orgEmail) {
    if (orgEmail.isEmpty) {
      return '';
    }

    List<String> list = orgEmail.split('@');
    if (list.length == 2) {
      var front = list.first;
      if (front.length > 3) {
        return '${front.substring(0, 3)}****${list.last}';
      } else {
        return orgEmail;
      }
    } else {
      return orgEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CloudColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const SizedBox(
              height: 35,
            ),
            Row(children: [
              Image.asset(
                'assets/images/icon_avatar.png',
                width: 48,
                height: 48,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                _email,
                style: const TextStyle(
                  color: CloudColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ]),
            const SizedBox(
              height: 17,
            ),
            Container(
              height: 76.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF3D2E24),
                    CloudColors.c63483D,
                    CloudColors.cBA987A,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '已成为追云加速VIP会员',
                          style: TextStyle(
                            color: CloudColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          '到期时间:$_expiredAt',
                          style: const TextStyle(
                              color: CloudColors.white, fontSize: 11),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/icon_vip_mark.png',
                      width: 81.5,
                      height: 39.5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: List.generate(_list.length, (index) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // if (index == 0) {
                    //   Modular.to.pushNamed('/cloud_order');
                    // } else if (index == 1) {
                    //   Modular.to.pushNamed('/cloud_invite');
                    // } else if (index == 2) {
                    //   Modular.to.pushNamed('/cloud_setting');
                    // }
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Image.asset(
                            //   'assets/icon_start.png',
                            //   width: 20,
                            //   height: 20,
                            // ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              _list[index],
                              style: const TextStyle(
                                fontSize: 15,
                                color: CloudColors.white,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/icon_next.png',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
