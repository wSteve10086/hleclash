import 'dart:io';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:flutter/material.dart';


class CloudAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CloudAppBar({
    super.key,
    this.title,
    this.backClick,
  });
  final String? title;
  final Function? backClick;

  @override
  Widget build(BuildContext context) {

    return AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      toolbarHeight:
          kToolbarHeight + ((Platform.isMacOS || Platform.isWindows) ? 20 : 0),
      title: Text(
        title ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(
            top: ((Platform.isMacOS || Platform.isWindows) ? 20 : 0)),
        child: IconButton(
          onPressed: () => backClick == null ? Navigator.pop(context) : backClick!(),
          icon: CloudThemeAsset(
            Assets.images.iconBack.path,
            width: 22,
            height: 22,
            tintInLight: true,
            tintInDark: true,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity,
      kToolbarHeight + ((Platform.isMacOS || Platform.isWindows) ? 20 : 0));
}
