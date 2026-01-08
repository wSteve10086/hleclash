import 'package:dio/dio.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_succeed/cloud_register_succeed_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
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
        backgroundColor: CloudColors.bg,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '创建密码',
                style: TextStyle(
                  color: CloudColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              const Text(
                '请创建长度至少为6个字符的密码',
                style: TextStyle(
                  color: CloudColors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              Container(
                height: 55,
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CloudColors.c242738,
                  border: Border.all(color: CloudColors.c5E6690, width: 1),
                ),
                child: TextField(
                  controller: _pwdController,
                  style:
                      const TextStyle(fontSize: 14, color: CloudColors.white),
                  obscureText: _obscureText,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '密码',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: CloudColors.c494D67),
                    focusedBorder: _inputBorder(),
                    disabledBorder: _inputBorder(),
                    errorBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    border: _inputBorder(),
                    contentPadding: EdgeInsets.zero,
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
                                child: Image.asset(
                                  _obscureText
                                      ? Assets.images.iconEyeClosed.path
                                      : Assets.images.iconEyeOpened.path,
                                  width: 20,
                                  height: 20,
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
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        CloudColors.c3257FF,
                        CloudColors.c24D4F3,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.isForgetPwd ? '重置密码' : '注册',
                      style: const TextStyle(
                        color: CloudColors.white,
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
      DioException error = e;
      var map = error.response?.data ?? {'message': '注册失败'};
      CloudToast.show(map['message'].toString(), context);
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

      DioException error = e;
      var map = error.response?.data ?? {'message': '重置密码失败'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  InputBorder _inputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 0, color: CloudColors.transparent),
    );
  }

  @override
  void dispose() {
    _pwdController.dispose();

    super.dispose();
  }
}
