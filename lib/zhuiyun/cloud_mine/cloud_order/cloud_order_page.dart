import 'dart:io';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_order_model.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay/cloud_pay_page.dart';
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

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      _loadData();
      _getGoodsPayMethod();
    });
  }

  Future<void> _loadData() async {
    CloudToast.loading(context);
    CloudRequest().getOrderList().then((CloudOrderModel m) async {
      CloudToast.hideLoading(context);

      if (m.status == 'success') {
        setState(() {
          _list = m.data ?? [];
        });
      } else {
        CloudToast.show(m.error.toString(), context);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);

      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  _getGoodsPayMethod() {
    CloudRequest().getPayMethod().then((m) async {
      var list = m.data?.toList();
      _paymethodID = '${list?.last.id}';
    }).catchError((e) {
      final DioException error = e;
      final map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
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
      body: ListView(
        children: List.generate(_list.length, (index) {
          Data data = _list[index];
          return Card(
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
                                color: CloudColors.cA4ADBD,
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 14,
                                color: CloudColors.cA4ADBD,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _getPayUrl(data.tradeNo ?? ''),
                          child: Container(
                            width: 100,
                            height: 34,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: CloudColors.c3257FF,
                            ),
                            child: const Text(
                              '付款',
                              style: TextStyle(
                                fontSize: 14,
                                color: CloudColors.white,
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
        }),
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
    if (tradeNo.isEmpty) {
      CloudToast.show('订单不存在', context);
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
    }).catchError((e) {
      CloudToast.hideLoading(context);
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  void _getPayUrl(String tradeNo) {
    if (tradeNo.isEmpty) {
      CloudToast.show('订单不存在', context);
      return;
    }
    // var loading = Loading.builder();
    // Asuka.addOverlay(loading);
    CloudRequest().getPayUrl(tradeNo, _paymethodID).then((m) async {
      // loading.remove();
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
    }).catchError((e) {
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  Widget _statusWidget(num status, BuildContext context) {
    if (status == 0) {
      return const Text(
        '待支付',
        style: TextStyle(fontSize: 14, color: CloudColors.c3257FF),
      );
    } else if (status == 2) {
      return const Text(
        '已取消',
        style: TextStyle(fontSize: 14, color: CloudColors.c5E6690),
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
