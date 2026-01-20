import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_goods_details/cloud_goods_details_page.dart';
import 'package:flutter/material.dart';

import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_model.dart';

import '../cloud_model/cloud_googs_conten_parser.dart';


class CloudFlowWidget extends StatelessWidget {
  const CloudFlowWidget({
    super.key,
    required this.list,
  });
  final List<Data> list;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: List.generate(list.length, (index) {
        final Data data = list[index];
        final content = data.content ?? '';
        final List<String> contentList = content.split('<br>\n');

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final num planId = data.id ?? 0;
            if (planId <= 0) {
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CloudGoodsDetailsPage(planId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Card(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      data.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          '低至：',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '￥${_getPrice(data)} ',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CloudColors.cEA0000),
                        ),
                        const Text(
                          '起',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildGoodsItem(list[index]),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }


  Widget buildGoodsItem(Data data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 套餐名
        Text(
          data.name ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        /// 价格（⚠️ 永远用字段，不用 HTML）
        if (data.monthPrice != null)
          Text('月付：￥${(data.monthPrice! / 100).toStringAsFixed(2)}'),
        if (data.quarterPrice != null)
          Text('季付：￥${(data.quarterPrice! / 100).toStringAsFixed(2)}'),
        if (data.halfYearPrice != null)
          Text('半年付：￥${(data.halfYearPrice! / 100).toStringAsFixed(2)}'),
        if (data.yearPrice != null)
          Text('年付：￥${(data.yearPrice! / 100).toStringAsFixed(2)}'),

        const SizedBox(height: 8),

        /// 权益列表
        ...data.parsedContentList.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(e)),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _getPrice(Data data) {
    var price = '0';
    if ((data.onetimePrice ?? 0) > 0) {
      price = (data.onetimePrice ?? 0).toString();
    } else if ((data.monthPrice ?? 0) > 0) {
      price = (data.monthPrice ?? 0).toString();
    } else if ((data.quarterPrice ?? 0) > 0) {
      price = (data.quarterPrice ?? 0).toString();
    } else if ((data.yearPrice ?? 0) > 0) {
      price = (data.yearPrice ?? 0).toString();
    }
    if (price.length >= 3) {
      return '${price.substring(0, price.length - 2)}.${price.substring(price.length - 2)}';
    } else {
      return '0.00';
    }
  }
}
