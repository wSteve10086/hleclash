import 'package:dio/dio.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_inviter_code/cloud_inviter_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_password/cloud_register_password_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/widgets/cloud_auth_header.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloudRegisterCodePage extends StatefulWidget {
  CloudRegisterCodePage(
      {super.key, required this.email, required this.isForgetPwd});
  String email = '';
  bool isForgetPwd = false;
  @override
  State<CloudRegisterCodePage> createState() => _CloudRegisterCodePageState();
}

class _CloudRegisterCodePageState extends State<CloudRegisterCodePage> {
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
              CloudAuthHeader(
                title: '输入验证码',
                subtitle: '请输入我们发送到${widget.email}的 6 位数验证码',
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '验证码',
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
                  opacity: _codeController.text.trim().isNotEmpty ? 1 : 0.55,
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
                onTap: () => _send(),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)),
                  child: Center(
                    child: Text(
                      '重发验证码',
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
    if (_codeController.text.isEmpty) {
      CloudToast.show('验证码不能为空', context);
      return;
    }

    if (widget.isForgetPwd) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CloudRegisterPasswordPage(
            widget.email,
            _codeController.text,
            '',
            widget.isForgetPwd,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CloudInviterPage(
            code: _codeController.text,
            email: widget.email,
          ),
        ),
      );
    }
  }

  Future<void> _send() async {
    CloudToast.loading(context);
    CloudRequest().sendEmail(widget.email).then((result) {
      CloudToast.hideLoading(context);

      if (result) {
        CloudToast.show('发送成功', context);
      } else {
        CloudToast.show('发送验证码失败', context);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);

      CloudToast.show(CloudRequest.errorMessage(e, fallback: '发送验证码失败'), context);
    });
  }

  InputBorder _inputBorder([Color color = CloudColors.transparent]) {
    return InputBorder.none;
  }

  @override
  void dispose() {
    _codeController.dispose();

    super.dispose();
  }
}
