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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final data = list[index];
        return _GoodsCard(
          data: data,
          onTap: () {
            final planId = data.id ?? 0;
            if (planId <= 0) return;
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => CloudGoodsDetailsPage(planId),
              ),
            );
          },
        );
      },
    );
  }
}

class _GoodsCard extends StatelessWidget {
  const _GoodsCard({required this.data, required this.onTap});

  final Data data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rights = data.parsedContentList;
    final visibleRights = rights.take(3).toList();
    final extraCount = rights.length - visibleRights.length;
    final bool isOnetimePlan = (data.onetimePrice ?? 0) > 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          data.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isOnetimePlan) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.orange.withOpacity(0.14),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.45),
                              ),
                            ),
                            child: const Text(
                              '限时返场',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '低至 ￥${_getPrice(data)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CloudColors.error(context),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildPriceChips(context, data),
              ),
              const SizedBox(height: 10),
              ...visibleRights.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    e,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              if (extraCount > 0)
                Text(
                  '还有 $extraCount 项权益，点击查看详情',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPriceChips(BuildContext context, Data data) {
    final items = <(String, num?)>[
      ('月付', data.monthPrice),
      ('季付', data.quarterPrice),
      ('半年付', data.halfYearPrice),
      ('年付', data.yearPrice),
      ('一次性', data.onetimePrice),
    ];
    return items
        .where((e) => (e.$2 ?? 0) > 0)
        .map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: CloudColors.brandPrimary(context).withOpacity(0.12),
            ),
            child: Text(
              '${e.$1} ￥${((e.$2 ?? 0) / 100).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        )
        .toList();
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
