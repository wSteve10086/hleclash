import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';

class CloudRegisterSucceedPage extends StatefulWidget {
  CloudRegisterSucceedPage({super.key, required this.isForgetPwd});
  bool isForgetPwd = false;

  @override
  State<CloudRegisterSucceedPage> createState() =>
      _CloudRegisterSucceedPageState();
}

class _CloudRegisterSucceedPageState extends State<CloudRegisterSucceedPage> {
  @override
  void initState() {
    super.initState();
    // 延时 2 秒自动跳转到首页
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloudAppBar(
        backClick: () {
          // Navigator.popUntil(context, (route) => Navigator.canPop(context));
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
      backgroundColor: CloudColors.bg,
      body: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            height: 94,
          ),
          Image.asset(
            Assets.images.iconSucceed.path,
            width: 55,
            height: 55,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            widget.isForgetPwd ? '重置密码成功' : '注册成功',
            style: const TextStyle(
              color: CloudColors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
