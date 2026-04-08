import 'package:dio/dio.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_succeed/cloud_register_succeed_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/widgets/cloud_auth_header.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';

class CloudRegisterPasswordPage extends StatefulWidget {
  const CloudRegisterPasswordPage(
      this.email, this.code, this.inviterCode, this.isForgetPwd,
      {super.key});
  final String email;
  final String code;
  final String inviterCode;
  final bool isForgetPwd;

  @override
  State<CloudRegisterPasswordPage> createState() =>
      _CloudRegisterPasswordPageState();
}

class _CloudRegisterPasswordPageState extends State<CloudRegisterPasswordPage> {
  final TextEditingController _pwdController = TextEditingController();
  bool _obscureText = true;

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
                title: '创建密码',
                subtitle: '请创建长度至少为6个字符的密码',
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
                  controller: _pwdController,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  obscureText: _obscureText,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '密码',
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
                    suffixIcon: _pwdController.text.isEmpty
                        ? const SizedBox()
                        : InkWell(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: CloudThemeAsset(
                                  _obscureText
                                      ? Assets.images.iconEyeClosed.path
                                      : Assets.images.iconEyeOpened.path,
                                  width: 20,
                                  height: 20,
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
                onTap: () => widget.isForgetPwd ? _resetPwd() : _register(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _pwdController.text.trim().isNotEmpty ? 1 : 0.55,
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
                      widget.isForgetPwd ? '重置密码' : '注册',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                      ),
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

  void _register() {
    if (_pwdController.text.isEmpty) {
      CloudToast.show('密码不能为空', context);
      return;
    }
    // var loading = Loading.builder();
    // Asuka.addOverlay(loading);
    CloudRequest()
        .register(
            email: widget.email,
            password: _pwdController.text,
            code: widget.code,
            inviterCode: widget.inviterCode)
        .then((m) {
      if (m.status == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CloudRegisterSucceedPage(
              isForgetPwd: widget.isForgetPwd,
            ),
          ),
        );
      } else {
        CloudToast.show('注册失败', context);
      }
      // loading.remove();
    }).catchError((e) {
      // loading.remove();
      CloudToast.show(CloudRequest.errorMessage(e, fallback: '注册失败'), context);
    });
  }

  void _resetPwd() {
    if (_pwdController.text.isEmpty) {
      CloudToast.show('密码不能为空', context);
      return;
    }
    CloudToast.loading(context);

    CloudRequest()
        .resetPwd(
            email: widget.email,
            password: _pwdController.text,
            code: widget.code)
        .then((result) {
      if (result) {
        CloudToast.hideLoading(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CloudRegisterSucceedPage(
              isForgetPwd: widget.isForgetPwd,
            ),
          ),
        );
      } else {
        CloudToast.show('重置密码失败', context);
      }
      // loading.remove();
    }).catchError((e) {
      // loading.remove();
      CloudToast.hideLoading(context);

      CloudToast.show(CloudRequest.errorMessage(e, fallback: '重置密码失败'), context);
    });
  }

  InputBorder _inputBorder([Color color = CloudColors.transparent]) {
    return InputBorder.none;
  }

  @override
  void dispose() {
    _pwdController.dispose();

    super.dispose();
  }
}
