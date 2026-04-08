import 'dart:io';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_pay_method.dart' as pm;
import 'package:fl_clash/zhuiyun/cloud_model/cloud_order_model.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay/cloud_pay_page.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay_failed/cloud_pay_failed.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay_succeed/cloud_pay_succeed.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CloudOrderPage extends StatefulWidget {
  const CloudOrderPage({super.key});

  @override
  State<CloudOrderPage> createState() => _CloudVipPageState();
}

class _CloudVipPageState extends State<CloudOrderPage> {
  var _list = <Data>[];
  String _paymethodID = '';
  List<pm.Data> _payMethods = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _getGoodsPayMethod();
    });

  }

  Future<void> _loadData() async {
    CloudToast.loading(context);
    CloudRequest().getOrderList().then((CloudOrderModel m) async {
      CloudToast.hideLoading(context);

      if (m.status == 'success') {
        if (!mounted) return;
        setState(() {
          _list = m.data ?? [];
          _loading = false;
        });
      } else {
        CloudToast.show(m.error.toString(), context);
        if (!mounted) return;
        setState(() => _loading = false);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);

      CloudToast.show(CloudRequest.errorMessage(e), context);
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  _getGoodsPayMethod() {
    CloudRequest().getPayMethod().then((m) async {
      final list = m.data?.toList() ?? <pm.Data>[];
      if (!mounted) return;
      setState(() {
        _payMethods = list;
        if (list.isNotEmpty) {
          _paymethodID = '${list.last.id}';
        }
      });
    }).catchError((e) {
      CloudToast.show(CloudRequest.errorMessage(e), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('我的订单'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 42,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无订单',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  itemCount: _list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
          Data data = _list[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${data.plan?.name}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis, // 根据需要设置文本溢出时的处理方式

                        ),
                      ),
                      _statusWidget(data.status ?? 0, context),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '订单号：${data.tradeNo}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '下单时间：${_timestampToDate((data.updatedAt ?? 0).toInt())}',
                    style: theme.textTheme.bodySmall?.copyWith(),
                  ),
                  Text(
                    '订单金额：￥${_getPrice(data)}',
                    style: theme.textTheme.bodySmall?.copyWith(),
                  ),
                  if ((data.discountAmount ?? 0) > 0)
                    Text(
                      '优惠金额(优惠券)：￥${_getTotalAmount((data.discountAmount ?? 0).toString())}',
                      style: theme.textTheme.bodySmall?.copyWith(),
                    ),
                  if ((data.surplusAmount ?? 0) > 0)
                    Text(
                      '旧订阅折抵金额：￥${_getTotalAmount((data.surplusAmount ?? 0).toString())}',
                      style: theme.textTheme.bodySmall?.copyWith(),
                    ),
                  if ((data.balanceAmount ?? 0) > 0)
                    Text(
                      '余额：￥${_getTotalAmount((data.balanceAmount ?? 0).toString())}',
                      style: theme.textTheme.bodySmall?.copyWith(),
                    ),
                  Text(
                    '支付金额：￥${_getTotalAmount((data.totalAmount ?? 0).toString())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        // color: theme.colorScheme.onSecondaryContainer,
                        ),
                  ),
                  if (data.status == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _cancelOrder(data.tradeNo ?? ''),
                          child: Container(
                            width: 100,
                            height: 34,
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: CloudColors.transparent,
                              border: Border.all(
                                color: theme.colorScheme.outline,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _submitting
                              ? null
                              : () => _showPayMethodSheet(data.tradeNo ?? ''),
                          child: Container(
                            width: 100,
                            height: 34,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: theme.colorScheme.primary,
                            ),
                            child: Text(
                              '付款',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        },
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

  void _cancelOrder(String tradeNo) {
    if (_submitting) return;
    _submitting = true;
    if (tradeNo.isEmpty) {
      CloudToast.show('订单不存在', context);
      _submitting = false;
      return;
    }
    CloudToast.loading(context);
    CloudRequest().cancelOrder(tradeNo).then((m) async {
      CloudToast.hideLoading(context);
      if (m) {
        CloudToast.show('订单取消成功', context);
        _loadData();
      } else {
        CloudToast.show('订单取消失败', context);
      }
      _submitting = false;
    }).catchError((e) {
      CloudToast.hideLoading(context);
      CloudToast.show(CloudRequest.errorMessage(e), context);
      _submitting = false;
    });
  }

  void _showPayMethodSheet(String tradeNo) {
    if (tradeNo.isEmpty) {
      CloudToast.show('订单不存在', context);
      return;
    }
    if (_payMethods.isEmpty) {
      _getPayUrl(tradeNo);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择支付方式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _payMethods.map((m) {
                    final id = '${m.id ?? ''}';
                    return ChoiceChip(
                      label: Text(m.name ?? '支付'),
                      selected: _paymethodID == id,
                      onSelected: (_) => setState(() => _paymethodID = id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _getPayUrl(tradeNo);
                    },
                    child: const Text('去支付'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _getPayUrl(String tradeNo) {
    if (_submitting) return;
    _submitting = true;
    if (tradeNo.isEmpty) {
      CloudToast.show('订单不存在', context);
      _submitting = false;
      return;
    }
    CloudToast.loading(context);
    CloudRequest().getPayUrl(tradeNo, _paymethodID).then((m) async {
      CloudToast.hideLoading(context);
      if (m.type == -1) {
        if (m.data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CloudPaySucceedPage(),
            ),
          );
        }
      } else {
        if (Platform.isMacOS || Platform.isWindows) {
          final webView = await WebviewWindow.create(
            configuration: CreateConfiguration(
              windowHeight: 680,
              windowWidth: 580,
              title: "支付",
              titleBarTopPadding: Platform.isMacOS ? 20 : 0,
            ),
          );
          webView.addOnUrlRequestCallback((url) {
            if (url.contains('trade_status=TRADE_SUCCES')) {
              webView.close();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CloudPaySucceedPage(),
                ),
              );
            } else if (url.contains('trade_status=TRADE_FAILED') ||
                url.contains('trade_status=TRADE_CLOSED')) {
              webView.close();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CloudPayFailedPage(),
                ),
              );
            }
          });
          webView.launch(m.data.toString());
        } else {
          final String payUrl = m.data.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CloudPayPage(payUrl),
            ),
          );
        }
      }
      _submitting = false;
    }).catchError((e) {
      CloudToast.hideLoading(context);
      CloudToast.show(CloudRequest.errorMessage(e), context);
      _submitting = false;
    });
  }

  Widget _statusWidget(num status, BuildContext context) {
    if (status == 0) {
      return Text(
        '待支付',
        style: TextStyle(fontSize: 14, color: CloudColors.brandPrimary(context)),
      );
    } else if (status == 2) {
      return Text(
        '已取消',
        style: TextStyle(fontSize: 14, color: CloudColors.muted(context)),
      );
    } else {
      return const Text(
        '已完成',
        style: TextStyle(fontSize: 14, color: Colors.orangeAccent),
      );
    }
  }

  String _getPrice(Data? data) {
    var price = '0';
    if (data?.period == 'onetime_price') {
      price = (data?.plan?.onetimePrice ?? 0).toString();
    } else if (data?.period == 'month_price') {
      price = (data?.plan?.monthPrice ?? 0).toString();
    } else if (data?.period == 'quarter_price') {
      price = (data?.plan?.quarterPrice ?? 0).toString();
    } else if (data?.period == 'year_price') {
      price = (data?.plan?.yearPrice ?? 0).toString();
    }
    if (price.length >= 3) {
      return '${price.substring(0, price.length - 2)}.${price.substring(price.length - 2)}';
    } else {
      return '0.00';
    }
  }
}
