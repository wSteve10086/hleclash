import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register_code/cloud_register_code_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/widgets/cloud_auth_header.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_app_bar.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/material.dart';

class CloudResetPasswordPage extends StatefulWidget {
  const CloudResetPasswordPage({super.key});

  @override
  State<CloudResetPasswordPage> createState() => _CloudResetPasswordPageState();
}

class _CloudResetPasswordPageState extends State<CloudResetPasswordPage> {
  final TextEditingController _emailController =
      TextEditingController(text: '');
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
                title: '无法登录？',
                subtitle: '请输入你的邮箱账号',
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
                  controller: _emailController,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
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
              if (!_isEmail)
                Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '请输入有效的邮箱',
                      style: TextStyle(
                        fontSize: 11,
                        color: CloudColors.error(context),
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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _emailController.text.trim().isNotEmpty ? 1 : 0.55,
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
                      '发送验证码',
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
              isForgetPwd: true,
              email: _emailController.text,
            ),
          ),
        );
      } else {
        CloudToast.show('发送验证码失败', context);
      }
    }).catchError((e) {
      CloudToast.hideLoading(context);
      CloudToast.show(
        CloudRequest.errorMessage(e, fallback: '发送验证码失败'),
        context,
      );
    });
  }

  InputBorder _inputBorder([Color color = CloudColors.transparent]) {
    return InputBorder.none;
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }
}
