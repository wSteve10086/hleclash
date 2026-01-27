import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateDownloadPage extends StatelessWidget {
  final String version;
  final List<String> updateLogs;
  final String downloadUrl;

  const UpdateDownloadPage({
    super.key,
    required this.version,
    required this.updateLogs,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('版本更新'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 标题
            Text(
              '发现新版本 v$version',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// 更新内容标题
            const Text(
              '更新内容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            ...updateLogs.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $e',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 下载地址标题
            const Text(
              '下载地址',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            /// 地址容器
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                downloadUrl,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 复制按钮
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: downloadUrl),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('下载地址已复制，请到浏览器粘贴下载'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                ),
                child: const Text('复制下载地址'),
              ),
            ),

            const SizedBox(height: 12),

            /// 提示说明
            const Text(
              '温馨提示：\n请打开系统浏览器，粘贴下载地址完成安装，建议下载好安装包后，先卸载本地版本在安装最新版本。',
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
