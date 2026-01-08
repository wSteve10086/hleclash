import 'package:dio/dio.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_code/cloud_register_code_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

class CloudRegisterPage extends StatefulWidget {
  const CloudRegisterPage({super.key});

  @override
  State<CloudRegisterPage> createState() => _CloudRegisterPageState();
}

class _CloudRegisterPageState extends State<CloudRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmail = true;

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
                '创建账号',
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
                '请输入能联系你上的邮箱',
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
                  border: Border.all(
                      color:
                          _isEmail ? CloudColors.c5E6690 : CloudColors.cEA0000,
                      width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  style:
                      const TextStyle(fontSize: 14, color: CloudColors.white),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (text) {
                    setState(() {
                      if (text.isEmpty) {
                        _isEmail = true;
                        return;
                      }
                      _isEmail = _isValid(text,
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '邮箱',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: CloudColors.c494D67),
                    focusedBorder: _inputBorder(),
                    disabledBorder: _inputBorder(),
                    errorBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    border: _inputBorder(),
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: _emailController.text.isEmpty
                        ? const SizedBox()
                        : InkWell(
                            onTap: () {
                              _emailController.clear();
                              setState(() {
                                _isEmail = true;
                              });
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: Image.asset(
                                  Assets.images.iconClear.path,
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              if (!_isEmail)
                const Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '请输入有效的邮箱',
                      style: TextStyle(
                        fontSize: 11,
                        color: CloudColors.cEA0000,
                      ),
                    )
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _send(),
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
                  child: const Center(
                    child: Text(
                      '发送验证码',
                      style: TextStyle(
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

  bool _isValid(String text, String regexp) {
    final regex = RegExp(regexp);
    return regex.hasMatch(text);
  }

  Future<void> _send() async {
    if (_emailController.text.isEmpty) {
      CloudToast.show('邮箱不能为空', context);
      return;
    }
    CloudToast.loading(context);
    CloudRequest().sendEmail(_emailController.text).then((result) {
      CloudToast.hideLoading(context);
      if (result) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CloudRegisterCodePage(
              email: _emailController.text,
              isForgetPwd: false,
            ),
          ),
        );
      } else {
        CloudToast.show('发送验证码失败', context);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);
      final DioException error = e;
      var map = error.response?.data ?? {'message': '发送验证码失败'};
      CloudToast.show(map['message'].toString(), context);
    });
  }

  InputBorder _inputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 0, color: CloudColors.transparent),
    );
  }
}
