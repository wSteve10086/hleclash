import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_password/cloud_register_password_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/widgets/cloud_auth_header.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:flutter/material.dart';

class CloudInviterPage extends StatefulWidget {
  CloudInviterPage({super.key, required this.email, required this.code});
  String email = '';
  String code = '';

  @override
  State<CloudInviterPage> createState() => _CloudInviterPageState();
}

class _CloudInviterPageState extends State<CloudInviterPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: const CloudAppBar(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              const CloudAuthHeader(
                title: '输入邀请码',
                subtitle: '请输入您推荐人的邀请码，注册成功之后，您购买套餐后，您好友会获取佣金返利哦',
              ),
              const SizedBox(
                height: 28,
              ),
              Container(
                height: 55,
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.32),
                ),
                child: TextField(
                  controller: _codeController,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '请输入推荐人邀请码',
                    hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    focusedBorder: _inputBorder(
                      Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    ),
                    disabledBorder: _inputBorder(),
                    errorBorder: _inputBorder(CloudColors.error(context)),
                    focusedErrorBorder: _inputBorder(CloudColors.error(context)),
                    enabledBorder: _inputBorder(),
                    border: _inputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: _codeController.text.isEmpty
                        ? const SizedBox()
                        : InkWell(
                            onTap: () {
                              _codeController.clear();
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: CloudThemeAsset(
                                  Assets.images.iconClear.path,
                                  width: 16,
                                  height: 16,
                                  tintInLight: true,
                                  tintInDark: true,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _next(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: 1,
                  child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '下一步',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _next(),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)),
                  child: Center(
                    child: Text(
                      '跳过',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    var inviterCode = _codeController.text;
    if (_codeController.text == "") {
      inviterCode = "dLjwlz8Y";
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CloudRegisterPasswordPage(
          widget.email,
          widget.code,
          inviterCode,
          false,
        ),
      ),
    );
  }

  InputBorder _inputBorder([Color color = CloudColors.transparent]) {
    return InputBorder.none;
  }
}
