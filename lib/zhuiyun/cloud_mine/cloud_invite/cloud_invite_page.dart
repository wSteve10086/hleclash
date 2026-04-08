import 'dart:convert';

import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_users_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_welfare_model.dart';
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

  String _inviteCodeFromModel(CloudInviteWelfareModel? m) {
    final d = m?.data;
    if (d == null) return '';
    final direct = d.inviteCode?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final list = List<Codes>.from(d.codes ?? []);
    list.sort(
      (a, b) => (b.updatedAt ?? b.createdAt ?? 0)
          .compareTo(a.updatedAt ?? a.createdAt ?? 0),
    );
    for (final c in list) {
      final s = c.code?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return '';
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('invite') ?? '';
    if (cached.isNotEmpty) {
      try {
        final model = CloudInviteWelfareModel.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _statList = model.data?.stat ?? [];
            _inviteCode = _inviteCodeFromModel(model);
          });
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final m = await CloudRequest().getInviteWelfare();
      if (!mounted) return;
      final ok = m.status == 'success' ||
          m.status == '1' ||
          (m.data != null &&
              ((m.data!.codes?.isNotEmpty ?? false) ||
                  (m.data!.inviteCode?.trim().isNotEmpty ?? false)));
      if (ok) {
        setState(() {
          _loading = false;
          _statList = m.data?.stat ?? [];
          _inviteCode = _inviteCodeFromModel(m);
        });
        await prefs.setString('invite', jsonEncode(m.toJson()));
      } else {
        setState(() => _loading = false);
        CloudToast.show(m.error?.toString() ?? '加载失败', context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      if (mounted) {
        CloudToast.show(CloudRequest.errorMessage(e), context);
      }
    }

    try {
      final users = await CloudRequest().getInviteUsers();
      if (!mounted) return;
      setState(() => _usersModel = users);
    } catch (e) {
      if (mounted) {
        CloudToast.show(
          CloudRequest.errorMessage(e, fallback: '邀请数据加载失败'),
          context,
        );
      }
    }
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
                  elevation: 0,
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
                  elevation: 0,
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
                                  color: theme.colorScheme.primary,
                                ),
                                child: Text(
                                  '复制邀请',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimary,
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
                                  color: theme.colorScheme.primary,
                                ),
                                child: Text(
                                  '复制邀请码',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimary,
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
                    elevation: 0,
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
                            child: (_usersModel?.data?.isEmpty ?? true)
                                ? Center(
                                    child: Text(
                                      '暂无返佣明细',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : ListView(
                                    children: List.generate(
                                  _usersModel?.data?.length ?? 0,
                                  (index) {
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
                                  },
                                ),
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
