import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_model.dart';

extension CloudGoodsContentParser on Data {
  /// 解析套餐权益列表
  List<String> get parsedContentList {
    if (content == null || content!.isEmpty) return [];

    final text = content!
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
}
