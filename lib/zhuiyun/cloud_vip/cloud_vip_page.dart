
import 'dart:convert';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:flutter/material.dart';

import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_model.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_flow_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cloud_state/vip_state.dart';

class CloudVipPage extends ConsumerStatefulWidget {
  const CloudVipPage({super.key});

  @override
  ConsumerState<CloudVipPage> createState() => _CloudVipPageState();
}

class _CloudVipPageState extends ConsumerState<CloudVipPage> {
  /// ⭐ 只保留一个套餐列表
  List<Data> _priceList = [];

  bool _loading = false;
  bool _showFullEmail = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), _loadData);
  }

  /// 邮箱脱敏
  String getEmail(String orgEmail) {
    if (orgEmail.isEmpty) return '';
    final list = orgEmail.split('@');
    if (list.length == 2 && list.first.length > 3) {
      return '${list.first.substring(0, 3)}****${list.last}';
    }
    return orgEmail;
  }

  /// 加载套餐数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString('vip_list');

    if (cache != null && cache.isNotEmpty) {
      final model =
      CloudGoodsModel.fromJson(jsonDecode(cache) as Map<String, dynamic>);
      _setGoodsList(model);
      return;
    }

    if (mounted) {
      setState(() => _loading = true);
    }

    CloudRequest().getGoodsList().then((m) {
      if (mounted) {
        setState(() => _loading = false);
      }

      if (m.status == 'success') {
        _setGoodsList(m);
        prefs.setString('vip_list', jsonEncode(m.toJson()));
      } else {
        CloudToast.show(m.error.toString(), context);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      CloudToast.show(CloudRequest.errorMessage(e), context);
    });
  }

  /// ⭐ 合并所有可用套餐
  void _setGoodsList(CloudGoodsModel m) {
    final list = m.data ?? <Data>[];
    if (!mounted) return;

    setState(() {
      _priceList = list.where((e) {
        return (e.monthPrice ?? 0) >= 1000 ||
            (e.quarterPrice ?? 0) >= 1000 ||
            (e.yearPrice ?? 0) >= 1000 ||
            (e.onetimePrice ?? 0) >= 1000;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vip = ref.watch(vipProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              /// 顶部会员信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '套餐商店',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CloudThemeAsset(
                              Assets.images.iconVipDefault.path,
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Text(
                                          _showFullEmail
                                              ? vip.email
                                              : getEmail(vip.email),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _showFullEmail = !_showFullEmail;
                                          });
                                        },
                                        child: Icon(
                                          _showFullEmail
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '到期时间：${vip.expiredAt}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '当前套餐：${vip.planName.isEmpty ? '未开通' : vip.planName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            CloudThemeAsset(
                              Assets.images.iconVipFlag.path,
                              width: 63,
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              /// ⭐ 唯一套餐列表
              Expanded(
                child: _priceList.isEmpty && !_loading
                    ? Center(
                        child: Text(
                          '暂无可购买套餐',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : CloudFlowWidget(
                        list: _priceList,
                      ),
              ),
            ],
          ),

          if (_loading) CloudToast.loadingWidget(),
        ],
      ),
    );
  }
}





// 旧代码
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:fl_clash/gen/assets.gen.dart';
// import 'package:flutter/material.dart';
//
// import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_model.dart';
// import 'package:fl_clash/zhuiyun/cloud_model/cloud_subscribe_model.dart'
//     as cloud;
// import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
// import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
// import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
// import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
// import 'package:fl_clash/zhuiyun/cloud_vip/cloud_flow_widget.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../cloud_state/vip_state.dart';
//
// class CloudVipPage extends ConsumerStatefulWidget {
//   const CloudVipPage({super.key});
//
//   @override
//   // State<CloudVipPage> createState() => _CloudVipPageState();
//   ConsumerState<CloudVipPage> createState() => _CloudVipPageState();
//
// }
//
// class _CloudVipPageState extends ConsumerState<CloudVipPage> {
//   int _tabIndex = 0;
//   // final _cloudRequest = Modular.get<CloudRequest>();
//   var _onetimePriceList = <Data>[];
//   var _quarterPriceList = <Data>[];
//   var _monthPriceList = <Data>[];
//   var _yearPriceList = <Data>[];
//   String _email = '';
//   String _expiredAt = '';
//   bool _loading = false;
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(const Duration(milliseconds: 100), () {
//       // _getSubscribe();
//       _loadData();
//     });
//   }
//
//   Future<void> _getSubscribe() async {
//     // final SharedPreferences prefs = await SharedPreferences.getInstance();
//     // final expired = prefs.getString('expired') ?? '';
//     // if (expired.isNotEmpty) {
//     //   final model = cloud.CloudSubscribeModel.fromJson(
//     //       jsonDecode(expired) as Map<String, dynamic>);
//     //   if (mounted) {
//     //     setState(() {
//     //       _expiredAt = getExpireAt(model.data?.expiredAt);
//     //       _email = getEmail(model.data?.email ?? '');
//     //     });
//     //   }
//     //   return;
//     // }
//     // CloudRequest().getSubscribe().then((value) {
//     //   if (mounted) {
//     //     setState(() {
//     //       _expiredAt = getExpireAt(value.data?.expiredAt);
//     //       _email = getEmail(value.data?.email ?? '');
//     //       prefs.setString('expired', jsonEncode(value.toJson()));
//     //     });
//     //   }
//     // }).catchError((e) {
//     //   DioException error = e;
//     //   var map = error.response?.data ?? {'message': '订阅异常'};
//     //   CloudToast.show(map['message'].toString(), context);
//     // });
//   }
//
//   // String getExpireAt(num? timestamp) {
//   //   if (timestamp == null) {
//   //     return '不限时长';
//   //   }
//   //   if (timestamp.toInt() * 1000 < DateTime.now().millisecondsSinceEpoch) {
//   //     return '已过期';
//   //   }
//   //   var date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
//   //   var formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
//   //   String formatted = formatter.format(date);
//   //   return formatted;
//   // }
//
//   String getEmail(String orgEmail) {
//     if (orgEmail.isEmpty) {
//       return '';
//     }
//
//     List<String> list = orgEmail.split('@');
//     if (list.length == 2) {
//       var front = list.first;
//       if (front.length > 3) {
//         return '${front.substring(0, 3)}****${list.last}';
//       } else {
//         return orgEmail;
//       }
//     } else {
//       return orgEmail;
//     }
//   }
//
//   Future<void> _loadData() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final vipList = prefs.getString('vip_list') ?? '';
//     if (vipList.isNotEmpty) {
//       final model =
//           CloudGoodsModel.fromJson(jsonDecode(vipList) as Map<String, dynamic>);
//       _setGoodsList(model);
//       return;
//     }
//     // CloudToast.loading(context);
//     if (mounted) {
//       setState(() {
//         _loading = true;
//       });
//     }
//     CloudRequest().getGoodsList().then((m) async {
//       // CloudToast.hideLoading(context);
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
//       if (m.status == 'success') {
//         _setGoodsList(m);
//         prefs.setString('vip_list', jsonEncode(m.toJson()));
//       } else {
//         CloudToast.show(m.error.toString(), context);
//       }
//     }).catchError((e) {
//       // CloudToast.hideLoading(context);
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
//       final DioException error = e;
//       var map = error.response?.data ?? {'message': '数据异常'};
//       CloudToast.show(map['message'].toString(), context);
//     });
//   }
//
//   void _setGoodsList(CloudGoodsModel m) {
//     var list = m.data ?? <Data>[];
//     if (mounted) {
//       setState(() {
//         _onetimePriceList =
//             list.where((e) => (e.onetimePrice ?? 0) >= 1000).toList();
//         _monthPriceList =
//             list.where((e) => (e.monthPrice ?? 0) >= 1000).toList();
//         _quarterPriceList =
//             list.where((e) => (e.quarterPrice ?? 0) >= 1000).toList();
//         _yearPriceList = list.where((e) => (e.yearPrice ?? 0) >= 1000).toList();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext) {
//     var size = MediaQuery.of(context).size;
//     final vip = ref.watch(vipProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('会员'),
//       ),
//       body:
//
//       Stack(
//         alignment: Alignment.center,
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 25,
//                     ),
//                     const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '商店',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ]),
//                     const SizedBox(
//                       height: 16,
//                     ),
//                     Card(
//                       child: SizedBox(
//                         height: 75,
//                         child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Image.asset(
//                                     Assets.images.iconVipDefault.path,
//                                     width: 40,
//                                     height: 40,
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         getEmail(vip.email),
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 2,
//                                       ),
//                                       Text(
//                                         '到期时间:${vip.expiredAt}',
//                                         style: const TextStyle(fontSize: 11),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Image.asset(
//                                 Assets.images.iconVipFlag.path,
//                                 width: 63,
//                                 height: 30,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//               _tabBarWidget(
//                   titles: [
//                     '月付套餐',
//                     '季付套餐',titles: [
//                       '月付套餐',
//                       '季付套餐',
//                       '年付套餐',
//                       '流量套餐',
//                     ],
//                     '年付套餐',
//                     '流量套餐',
//                   ],
//                   curIndex: _tabIndex,
//                   tabClick: (int index) {
//                     setState(() {
//                       _tabIndex = index;
//                     });
//                   }),
//               SizedBox(
//                 height:
//                     Platform.isAndroid ? size.height - 385 : size.height - 302,
//                 width: size.width,
//                 child: IndexedStack(
//                   index: _tabIndex,
//                   children: [
//                     CloudFlowWidget(
//                       list: _monthPriceList,
//                     ),
//                     CloudFlowWidget(
//                       list: _quarterPriceList,
//                     ),
//                     CloudFlowWidget(
//                       list: _yearPriceList,
//                     ),
//                     CloudFlowWidget(
//                       list: _onetimePriceList,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_loading) CloudToast.loadingWidget(),
//         ],
//       ),
//     );
//   }
//
//   Widget _tabBarWidget(
//       {required int curIndex,
//       required List<String> titles,
//       required Function(int) tabClick}) {
//     final theme = Theme.of(context);
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Card(
//         child: SizedBox(
//           height: 40,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(
//               titles.length,
//               (index) => GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () => tabClick(index),
//                 child: Container(
//                   height: 46,
//                   alignment: Alignment.center,
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child:
//                         Text(
//                           titles[index],
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: index == curIndex
//                                   ? CloudColors.c2D79FB
//                                   : theme.colorScheme.onSecondaryContainer),
//                         ),
//                       ),
//                       if (index == curIndex)
//                         Positioned(
//                           bottom: 0,
//                           child: Container(
//                             height: 1.5,
//                             padding: const EdgeInsets.symmetric(horizontal: 2),
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 colors: [
//                                   CloudColors.c2D79FB.withOpacity(0.3),
//                                   CloudColors.c2D79FB,
//                                   CloudColors.c2D79FB.withOpacity(0.3),
//                                 ],
//                               ),
//                             ),
//                             child: Text(
//                               titles[index],
//                               style: const TextStyle(
//                                   fontSize: 14, color: CloudColors.transparent),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
