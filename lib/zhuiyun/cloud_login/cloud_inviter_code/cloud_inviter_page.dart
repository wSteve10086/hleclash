import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_password/cloud_register_password_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
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
        backgroundColor: CloudColors.bg,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '输入邀请码',
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
                '请输入您推荐人的邀请码，注册成功之后，您购买套餐后，您好友会获取佣金返利哦',
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
                  controller: _codeController,
                  style:
                      const TextStyle(fontSize: 14, color: CloudColors.white),
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '请输入推荐人邀请码',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: CloudColors.c494D67),
                    focusedBorder: _inputBorder(),
                    disabledBorder: _inputBorder(),
                    errorBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    border: _inputBorder(),
                    contentPadding: EdgeInsets.zero,
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
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _next(),
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
                      '下一步',
                      style: TextStyle(
                        color: CloudColors.white,
                        fontSize: 15,
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
                      border: Border.all(color: CloudColors.c5E6690, width: 1)),
                  child: const Center(
                    child: Text(
                      '跳过',
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

  InputBorder _inputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 0, color: CloudColors.transparent),
    );
  }
}
