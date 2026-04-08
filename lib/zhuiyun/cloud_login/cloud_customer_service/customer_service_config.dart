import 'package:fl_clash/zhuiyun/cloud_model/CloudVersionStorage.dart';

/// 客服链接无下发时的默认 Crisp 地址。
const String kCustomerServiceCrispEmbedUrl =
    'https://go.crisp.chat/chat/embed/?website_id=36c7c66a-f768-4354-9823-5aaefec60c81';

/// 客服链接优先使用版本接口下发值；无值时回退默认 Crisp。
String getCustomerServiceUrl() {
  final v = CloudVersionStorage.instance.model?.data?.customerServiceUrl?.trim();
  if (v != null && v.isNotEmpty) return v;
  return kCustomerServiceCrispEmbedUrl;
}

