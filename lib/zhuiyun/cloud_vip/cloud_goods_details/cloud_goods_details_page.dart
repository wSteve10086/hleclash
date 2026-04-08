import 'dart:io';
import 'package:fl_clash/zhuiyun/cloud_mine/cloud_order/cloud_order_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_coupon_model.dart' as coupon;
import 'package:fl_clash/zhuiyun/cloud_model/cloud_order_model.dart' as o;
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay/cloud_pay_page.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_pay_succeed/cloud_pay_succeed.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_details_model.dart';

class CloudGoodsDetailsPage extends StatefulWidget {
  const CloudGoodsDetailsPage(this.planId, {super.key});
  final num planId;

  @override
  State<CloudGoodsDetailsPage> createState() => _CloudGoodsDetailsPageState();
}

class _CloudGoodsDetailsPageState extends State<CloudGoodsDetailsPage> {
  final TextEditingController _couponController = TextEditingController();

  List<String> _contentList = [];
  Data? _detailDate;
  String _tradeNo = '';
  String _discountAmount = '';
  String _surplusAmount = '';
  String _balanceAmount = '';
  String _totalAmount = '';
  String _paymethodID = '';
  List<String> _goodsTypeList = [];
  List<String> _goodsTypeNameList = [];
  String? selectedOption = "月付"; // 记录当前选中的选项
  String _period = 'month_price';
  coupon.Data? _couponData;
  bool _couponApplied = false;
  int _couponDiscountCents = 0;

  BuildContext? _sheetContext;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _loadData();
      _getGoodsPayMethod();
    });
  }

  void _loadData() {
    CloudToast.loading(context);
    CloudRequest().getGoodsDetails(widget.planId).then((m) async {
      CloudToast.hideLoading(context);
      if (m.status == 'success') {
        if (mounted) {
          setState(() {
            final content = m.data?.content ?? '';
            // _contentList = content.split('<br>\n');
            _contentList = getContent(m.data?.content ?? '');
            _detailDate = m.data;
            /// 判断套餐支持付款类型
            _getPaymentCycle();

          });
        }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (_sheetContext != null) {
          if (Navigator.canPop(_sheetContext!)) {
            Navigator.pop(_sheetContext!);
          }
        }
        return true;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _hideKeyboard(),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('商品明细'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.45),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _detailDate?.name ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  '低至：',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '￥${_getPrice()} ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.error),
                                ),
                                const Text(
                                  '起',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),


                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                _contentList.length,
                                    (i) => Text(
                                  _contentList[i]
                                      .trim()
                                      .replaceAll('<br>', '')
                                      .replaceAll('&#x2714', '✅'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _goodsTypeList.length < 2
                    ? const SizedBox.shrink()
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_goodsTypeNameList.length, (index) {
                          final option = _goodsTypeNameList[index];
                          return ChoiceChip(
                            label: Text(option),
                            selected: selectedOption == option,
                            onSelected: (_) {
                              setState(() {
                                selectedOption = option;
                                _period = _goodsTypeList[index];
                                _recomputeCouponPreview();
                              });
                            },
                          );
                        }),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.45),
                    ),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 12),
                        const Text(
                          '优惠券码：',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _couponController,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              )),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _checkCoupon(),
                          child: Container(
                            height: 40,
                            width: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.colorScheme.primary,
                            ),
                            child: Text(
                              '验证',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.45),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    16 + (Platform.isAndroid ? 34 : 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '订单金额：',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          if (_couponApplied && _couponDiscountCents > 0)
                            Text(
                              '￥${_formatCents(_currentPriceCents())}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (_couponApplied && _couponDiscountCents > 0)
                            const SizedBox(width: 6),
                          Text(
                            '￥${_formatCents(_previewPayableCents())}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _checkOrder(),
                        child: Container(
                          height: 30,
                          width: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: theme.colorScheme.primary,
                          ),
                          child: Text(
                            '立即购买',
                            style: TextStyle(color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  List<String> getContent(String content) {
    if (content.isEmpty) return [];

    final text = content
        .replaceAll('\n', '')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll('&#x2714;', '✅');

    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => RegExp(r'^[①②③④⑤⑥⑦⑧⑨]').hasMatch(e))
        .toList();
  }



  _checkCoupon() {
    if (_couponController.text.trim().isEmpty) {
      CloudToast.show('请输入优惠券码', context);
      return;
    }
    CloudToast.loading(context);
    CloudRequest()
        .checkCoupon(_couponController.text, widget.planId)
        .then((m) async {
      CloudToast.hideLoading(context);
      if (m.status == 'success') {
        setState(() {
          _couponData = m.data;
          _couponApplied = true;
          _recomputeCouponPreview();
        });
        CloudToast.show('验证成功', context);
      } else {
        setState(() {
          _couponApplied = false;
          _couponDiscountCents = 0;
          _couponData = null;
        });
        CloudToast.show('验证失败', context);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);
      setState(() {
        _couponApplied = false;
        _couponDiscountCents = 0;
      });
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  void _buy() {
    final theme = Theme.of(context);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext sheetContext) {
          _sheetContext = sheetContext;
          return Container(
            height: 300,
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 48,
                      width: 48,
                    ),
                    Text(
                      '确认订单',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CloudColors.textPrimary(context),
                      ),
                    ),
                    IconButton(
                      iconSize: 48,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _sheetContext = null;
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '订单金额',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '￥${_getPrice()}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '优惠金额(优惠券)',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '￥${_getTotalAmount(_discountAmount)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_getTotalAmount(_surplusAmount) != '0.00')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '旧订阅折抵金额',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '￥${_getTotalAmount(_surplusAmount)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      SizedBox(
                          height: _getTotalAmount(_surplusAmount) != '0.00'
                              ? 10
                              : 0),
                      if (_getTotalAmount(_balanceAmount) != '0.00')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '余额',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '￥${_getTotalAmount(_balanceAmount)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      SizedBox(
                          height: _getTotalAmount(_balanceAmount) != '0.00'
                              ? 10
                              : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '支付金额',
                            style: TextStyle(fontSize: 14),

                          ),
                          Text(
                            '￥${_getTotalAmount(_totalAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _sheetContext = null;
                    _getPayUrl();
                  },
                  child: Container(
                    height: 40,
                    width: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.primary,
                    ),
                    child: Text(
                      '立即支付',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20 + (Platform.isAndroid ? 34 : 0),
                ),
              ],
            ),
          );
        });
  }




  void _checkOrder() {
    CloudToast.loading(context);
    CloudRequest().getOrderList().then((o.CloudOrderModel m) async {
      CloudToast.hideLoading(context);
      if (m.status == 'success') {
        var allList = m.data ?? [];
        var orderList = allList.where((element) => element.status == 0);
        if (orderList.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CloudOrderPage(),
            ),
          );
        } else {
          _getTradeNo();
        }
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

  void _getTradeNo() {
    CloudToast.loading(context);
    CloudRequest()
        .getTradeNo(_period, widget.planId, _couponController.text)
        .then((m) async {
      CloudToast.hideLoading(context);
      _tradeNo = m;

      _getOrderDetails();
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
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  void _getOrderDetails() {
    CloudToast.loading(context);
    CloudRequest().getOrderDetails(_tradeNo).then((m) async {
      CloudToast.hideLoading(context);
      _discountAmount = (m.data?.discountAmount ?? 0).toString();
      _surplusAmount = (m.data?.surplusAmount ?? 0).toString();
      _balanceAmount = (m.data?.balanceAmount ?? 0).toString();
      _totalAmount = (m.data?.totalAmount ?? 0).toString();

      _buy();
    }).catchError((e) {
      CloudToast.hideLoading(context);
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  _getPayUrl() {
    if (_tradeNo.isEmpty) {
      CloudToast.show('订单生成失败', context);
      return;
    }
    CloudToast.loading(context);
    CloudRequest().getPayUrl(_tradeNo, _paymethodID).then((m) async {
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
      CloudToast.hideLoading(context);
      DioException error = e;
      var map = error.response?.data ?? {'message': '数据异常'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  String _getPrice() {
    return _formatCents(_currentPriceCents());

    /*
    if ((_data?.onetimePrice ?? 0) > 0) {
      _period = 'onetime_price';
      price = (_data?.onetimePrice ?? 0).toString();
    }
   else if ((_data?.monthPrice ?? 0) > 0) {
      _period = 'month_price';
      price = (_data?.monthPrice ?? 0).toString();
    }
    else if ((_data?.quarterPrice ?? 0) > 0) {
      _period = 'quarter_price';
      price = (_data?.quarterPrice ?? 0).toString();
    }
    else if ((_data?.halfYearPrice ?? 0) > 0) {
      _period = 'half_year_price';
      price = (_data?.halfYearPrice ?? 0).toString();
    }
    else  if ((_data?.yearPrice ?? 0) > 0) {
      _period = 'year_price';
      price = (_data?.yearPrice ?? 0).toString();
    }
    if (price.length >= 3) {
      return '${price.substring(0, price.length - 2)}.${price.substring(price.length - 2)}';
    } else {
      return '0.00';
    }

     */
  }

  int _currentPriceCents() {
    if (_period == 'onetime_price') return (_detailDate?.onetimePrice ?? 0).toInt();
    if (_period == 'month_price') return (_detailDate?.monthPrice ?? 0).toInt();
    if (_period == 'quarter_price') return (_detailDate?.quarterPrice ?? 0).toInt();
    if (_period == 'half_year_price') return (_detailDate?.halfYearPrice ?? 0).toInt();
    if (_period == 'year_price') return (_detailDate?.yearPrice ?? 0).toInt();
    if (_period == 'two_year_price') return (_detailDate?.twoYearPrice ?? 0).toInt();
    if (_period == 'three_year_price') return (_detailDate?.threeYearPrice ?? 0).toInt();
    return 0;
  }

  int _previewPayableCents() {
    final base = _currentPriceCents();
    final payable = base - _couponDiscountCents;
    return payable < 0 ? 0 : payable;
  }

  void _recomputeCouponPreview() {
    final base = _currentPriceCents();
    if (!_couponApplied || _couponData == null || base <= 0) {
      _couponDiscountCents = 0;
      return;
    }
    final type = (_couponData?.type ?? 0).toInt();
    final value = (_couponData?.value ?? 0).toDouble();
    int discount = 0;
    if (type == 2) {
      // type=2: percent discount (e.g. 20 => 20% off)
      discount = (base * (value / 100)).round();
    } else {
      // default: fixed amount in cents
      discount = value.round();
    }
    if (discount < 0) discount = 0;
    if (discount > base) discount = base;
    _couponDiscountCents = discount;
  }

  String _formatCents(int cents) {
    final safe = cents < 0 ? 0 : cents;
    final amount = safe.toString();
    if (amount.length >= 3) {
      return '${amount.substring(0, amount.length - 2)}.${amount.substring(amount.length - 2)}';
    }
    if (amount.length == 2) return '0.$amount';
    if (amount.length == 1) return '0.0$amount';
    return '0.00';
  }


  void _getPaymentCycle(){
    if ((_detailDate?.onetimePrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('onetime_price');
      _goodsTypeNameList.add("一次性");
    }
    if ((_detailDate?.monthPrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('month_price');
      _goodsTypeNameList.add("月付");
    }
    if ((_detailDate?.quarterPrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('quarter_price');
      _goodsTypeNameList.add("季付");
    }
    if ((_detailDate?.halfYearPrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('half_year_price');
      _goodsTypeNameList.add("半年付");
    }

    if ((_detailDate?.yearPrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('year_price');
      _goodsTypeNameList.add("年付");
    }

    if ((_detailDate?.twoYearPrice ?? 0) > 0) {
      // _period = ;
      _goodsTypeList.add('two_year_price');
      _goodsTypeNameList.add("两年付");
    }

    if ((_detailDate?.threeYearPrice ?? 0) > 0) {
      // _period = 'three_year_price';
      _goodsTypeList.add('three_year_price');
      _goodsTypeNameList.add("三年付");
    }

    _period =  _goodsTypeList.first;
    selectedOption = _goodsTypeNameList.first;
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

  @override
  void dispose() {
    _sheetContext = null;
    _couponController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

