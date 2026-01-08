import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_users_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_welfare_model.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudInvitePage extends StatefulWidget {
  const CloudInvitePage({super.key});

  @override
  State<CloudInvitePage> createState() => _CloudInvitePageState();
}

class _CloudInvitePageState extends State<CloudInvitePage> {
  List<num> _statList = [];
  CloudInviteUsersModel? _usersModel;
  String _inviteCode = '';
  bool _loading = false;
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final vipList = prefs.getString('invite') ?? '';
    if (vipList.isNotEmpty) {
      final model = CloudInviteWelfareModel.fromJson(
          jsonDecode(vipList) as Map<String, dynamic>);
      if (mounted) {
        setState(() {
          _statList = model.data?.stat ?? [];
          var codes = model.data?.codes ?? [];
          if (codes.isNotEmpty) {
            _inviteCode = codes.last.code ?? '';
          }
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
    CloudRequest().getInviteWelfare().then((CloudInviteWelfareModel m) async {
      if (m.status == 'success') {
        if (mounted) {
          setState(() {
            _loading = false;
            _statList = m.data?.stat ?? [];
            var codes = m.data?.codes ?? [];
            if (codes.isNotEmpty) {
              _inviteCode = codes.last.code ?? '';
            }
          });
          prefs.setString('invite', jsonEncode(m.toJson()));
        }
      } else {
        CloudToast.show(m.error.toString(), context);
      }
      // loading.remove();
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });

    CloudRequest().getInviteUsers().then((CloudInviteUsersModel m) async {
      _usersModel = m;
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀请返利'),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  '我的返利',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              _statList.length > 4
                                  ? _getTotalAmount(_statList[0].toString())
                                  : '0.00',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '邀请用户',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              _statList.length > 4
                                  ? _getTotalAmount(_statList[1].toString())
                                  : '0.00',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '可提现佣金',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              _statList.length > 4
                                  ? _getTotalAmount(_statList[2].toString())
                                  : '0.00',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '确认中佣金',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              _statList.length > 4 ? '${_statList[3]}%' : '0%',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '佣金比例',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '我的邀请码',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _inviteCode,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_inviteCode.isEmpty) {
                                  return;
                                }

                                CloudRequest()
                                    .getInviteUrl(_inviteCode)
                                    .then((inviteUrl) {
                                  Clipboard.setData(
                                      ClipboardData(text: inviteUrl));
                                  CloudToast.show('复制邀请成功', context);
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: CloudColors.c2D79FB,
                                ),
                                child: const Text(
                                  '复制邀请',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CloudColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_inviteCode.isEmpty) {
                                  return;
                                }
                                Clipboard.setData(
                                    ClipboardData(text: _inviteCode));
                                CloudToast.show('复制邀请码成功', context);
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: CloudColors.c2D79FB,
                                ),
                                child: const Text(
                                  '复制邀请码',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CloudColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '邀请返佣明细',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '佣金(￥)',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '到账时间',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView(
                              children: List.generate(
                                  _usersModel?.data?.length ?? 0, (index) {
                                final m = _usersModel!.data![index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getTotalAmount(m.getAmount.toString()),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _timestampToDate(
                                            (m.createdAt ?? 0).toInt()),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading) CloudToast.loadingWidget(),
        ],
      ),
    );
  }

  String _timestampToDate(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    String formatted = formatter.format(date);
    return formatted;
  }

  String _getTotalAmount(String totalAmount) {
    if (totalAmount.length >= 3) {
      return '${totalAmount.substring(0, totalAmount.length - 2)}.${totalAmount.substring(totalAmount.length - 2)}';
    } else if (totalAmount.length >= 2) {
      return '0.$totalAmount';
    } else if (totalAmount.isNotEmpty) {
      return '0.0$totalAmount';
    } else {
      return '0.00';
    }
  }
}
