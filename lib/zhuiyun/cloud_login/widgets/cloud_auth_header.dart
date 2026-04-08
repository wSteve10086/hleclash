import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';

class CloudAuthHeader extends StatelessWidget {
  const CloudAuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ??
              TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: subtitleStyle ??
                TextStyle(
                  color: CloudColors.muted(context),
                  fontSize: 13,
                ),
          ),
        ],
      ],
    );
  }
}
