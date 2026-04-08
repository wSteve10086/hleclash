import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// 支持多个新域名轮流替换节点
String replaceAllProxyServer(
    String config, {
      required List<String> newServers, // 新域名列表
      List<String> protocolWhitelist = const [], // 协议白名单；空=不过滤
    }) {
  if (newServers.isEmpty) return config;

  final doc = loadYaml(config);
  if (doc is! YamlMap) return config;

  final proxies = doc['proxies'];
  if (proxies is! YamlList) return config;

  final editor = YamlEditor(config);
  int index = 0;
  final whitelist = protocolWhitelist
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toSet();

  for (int i = 0; i < proxies.length; i++) {
    final proxy = proxies[i];
    if (proxy is! YamlMap) continue;

    final server = proxy['server'];
    final sni = proxy['sni'];
    final type = proxy['type']?.toString().toLowerCase();

    if (server is! String || server.isEmpty) continue;
    if (whitelist.isNotEmpty && (type == null || !whitelist.contains(type))) {
      continue;
    }

    // ✅ 关键：判断是否直连
    final isDirect = (sni == null || sni == server);

    if (!isDirect) {
      final replacement = newServers[index % newServers.length];
      editor.update(['proxies', i, 'server'], replacement);
      index++;
    }
  }

  return editor.toString();
}
