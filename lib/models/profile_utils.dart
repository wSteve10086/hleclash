import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// 支持多个新域名轮流替换节点
String replaceAllProxyServer(
    String config, {
      required List<String> newServers, // 新域名列表
    }) {
  if (newServers.isEmpty) return config;

  final doc = loadYaml(config);
  if (doc is! YamlMap) return config;

  final proxies = doc['proxies'];
  if (proxies is! YamlList) return config;

  final editor = YamlEditor(config);
  int index = 0;

  for (int i = 0; i < proxies.length; i++) {
    final proxy = proxies[i];
    if (proxy is! YamlMap) continue;

    final server = proxy['server'];
    if (server is String && server.isNotEmpty) {
      // 轮流取 newServers
      final replacement = newServers[index % newServers.length];
      editor.update(['proxies', i, 'server'], replacement);
      index++;
    }
  }

  return editor.toString();
}
