import 'dart:io';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_customer_service/cloud_customer_service_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register/cloud_register_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_reset_password/cloud_reset_password_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_login_state.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cloud_model/CloudVersionStorage.dart';
import '../cloud_model/cloud_version_model.dart';
import '../cloud_utils/announcement_manager.dart';

class CloudLoginPage extends StatefulWidget {
  const CloudLoginPage({super.key});

  @override
  State<CloudLoginPage> createState() => _CloudLoginPageState();
}

class _CloudLoginPageState extends State<CloudLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _obscure = true;
  bool _isLoggingIn = false;
  int _tapCount = 0;

  /// ===== 公告相关 =====
  bool _showRedDot = false;
  final CloudVersionModel? _announcementData = CloudVersionStorage.instance.model;

  bool get _isEmailEmpty => _emailController.text.isEmpty;
  bool get _isPasswordEmpty => _pwdController.text.isEmpty;

  @override
  void initState() {
    super.initState();
    _initAnnouncement();
  }

  Future<void> _initAnnouncement() async {
    try {
      if (_announcementData == null) return;

      bool unread =
      await AnnouncementManager.hasUnread(_announcementData.data);

      if (!mounted) return;

      setState(() {
        _showRedDot = unread;
      });
    } catch (e) {
      debugPrint('公告初始化异常: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  /// ===== 公告 icon =====
  Widget _buildAnnouncementIcon() {
    return Positioned(
      top: 50,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (_announcementData != null) {
            _showAnnouncementDialog(_announcementData);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.volume_up,
                  size: 22,
                  color: CloudColors.white,
                ),
                SizedBox(width: 4),
                Text(
                  '公告',
                  style: TextStyle(
                    color: CloudColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            /// 红点
            if (_showRedDot)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  /// ===== 公告弹窗 =====
  void _showAnnouncementDialog(CloudVersionModel model) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(model.data?.title ?? "公告"),
          content: SingleChildScrollView(
            child: Text(model.data?.content ?? ""),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final urlStr = (model.data?.imgUrl?.isNotEmpty ?? false)
                    ? model.data!.imgUrl!
                    : '';
                if (urlStr.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                if (await canLaunchUrl(Uri.parse(urlStr))) {
                  await launchUrl(
                    Uri.parse(urlStr),
                    mode:
                    LaunchMode.externalApplication,
                  );
                  Navigator.pop(context);
                } else {
                  CloudToast.show('无法打开官网', context);
                }
              },
              child: Text(model.data?.btnTitle ?? "关闭"),
            ),
          ],
        );
      },
    );

    await AnnouncementManager.markAsRead();

    if (mounted) {
      setState(() {
        _showRedDot = false;
      });
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloudColors.bg,
      resizeToAvoidBottomInset: false,
      floatingActionButton:_buildServiceButton(),
      body: Stack(
        children: [
          _buildBody(context),
          _buildAnnouncementIcon(),
        ],
      ),

    );
  }


  /// ===== 原页面UI =====
  Widget _buildBody(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _hideKeyboard(context),
      child: Column(
        children: [
          const SizedBox(height: 115),
          Image.asset(Assets.images.iconLoginTop.path, width: 65, height: 65),
          const SizedBox(height: 18),
          // 邮箱输入框
          _buildTextField(
            controller: _emailController,
            hint: '邮箱',
            keyboardType: TextInputType.emailAddress,
            suffix: !_isEmailEmpty
                ? InkWell(
              onTap: () => setState(() => _emailController.clear()),
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
            )
                : null,
            onTap: _onEmailFieldTap,
          ),
          const SizedBox(height: 12),
          // 密码输入框
          _buildTextField(
            controller: _pwdController,
            hint: '密码',
            obscureText: _obscure,
            suffix: !_isPasswordEmpty
                ? InkWell(
              onTap: () => setState(() => _obscure = !_obscure),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Image.asset(
                    _obscure
                        ? Assets.images.iconEyeClosed.path
                        : Assets.images.iconEyeOpened.path,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            )
                : null,
          ),
          const SizedBox(height: 15),
          // 登录按钮
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _login(context),
            child: Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [CloudColors.c3257FF, CloudColors.c24D4F3],
                ),
              ),
              child: const Center(
                child: Text(
                  '登录',
                  style: TextStyle(color: CloudColors.white, fontSize: 15),
                ),
              ),
            ),
          ),
          // 忘记密码
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudResetPasswordPage()),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '忘记密码',
                style: TextStyle(fontSize: 13, color: CloudColors.white),
              ),
            ),
          ),
          const Spacer(), // 自动填充空间，避免写死 50px
          // 创建账户
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudRegisterPage()),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '创建账户',
                style: TextStyle(fontSize: 13, color: CloudColors.c3254FF),
              ),
            ),
          ),
          // 官网入口
          GestureDetector(
            onTap: () async {
              const url = 'https://fastfly.club';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              } else {
                CloudToast.show('无法打开官网', context);
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                '永久跳转网站:fastfly.club',
                style: TextStyle(
                  fontSize: 13,
                  color: CloudColors.c3254FF,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== 客服按钮 =====
  Widget _buildServiceButton() {
    return FloatingActionButton(
      child: const Text('客服'),
      onPressed: () async {
        if (Platform.isMacOS || Platform.isWindows) {
          final webView = await WebviewWindow.create(
            configuration: CreateConfiguration(
              windowHeight: 680,
              windowWidth: 580,
              title: '客服',
              titleBarTopPadding: Platform.isMacOS ? 20 : 0,
            ),
          );
          webView.launch(
              'https://go.crisp.chat/chat/embed/?website_id=36c7c66a-f768-4354-9823-5aaefec60c81');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CloudCustomerServicePage()),
          );
        }
      },
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CloudColors.c242738,
        border: Border.all(color: CloudColors.c5E6690, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: CloudColors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: (_) => setState(() {}),
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: CloudColors.c494D67),
          focusedBorder: _inputBorder(),
          disabledBorder: _inputBorder(),
          errorBorder: _inputBorder(),
          focusedErrorBorder: _inputBorder(),
          enabledBorder: _inputBorder(),
          border: _inputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  InputBorder _inputBorder() => const OutlineInputBorder(
    borderSide: BorderSide(width: 0, color: CloudColors.transparent),
  );

  void _hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _onEmailFieldTap() {
    if (!kDebugMode) return;

    _tapCount++;
    if (_tapCount == 2) {
      _emailController.text = "87764302012@gmail.com";
      _pwdController.text = "87764302012";
      CloudToast.show("切换到测试账号 1", context);
    } else if (_tapCount == 3) {
      _emailController.text = "77764302012@gmail.com";
      _pwdController.text = "77764302012";
      CloudToast.show("切换到测试账号 2", context);
    } else if (_tapCount == 4) {
      _emailController.text = "77764302012@gmail.com";
      _pwdController.text = "77764302012";
      CloudToast.show("切换到测试账号 3", context);
      _tapCount = 0;
    }
  }

  Future<void> _login(BuildContext context) async {
    if (_isLoggingIn) return;
    _isLoggingIn = true;

    final email = _emailController.text.trim();
    final password = _pwdController.text.trim();

    if (email.isEmpty) {
      CloudToast.show('邮箱不能为空', context);
      _isLoggingIn = false;
      return;
    }
    if (password.isEmpty) {
      CloudToast.show('密码不能为空', context);
      _isLoggingIn = false;
      return;
    }

    _hideKeyboard(context);
    CloudToast.loading(context);

    try {
      final m = await CloudRequest().login(email: email, password: password);
      CloudToast.hideLoading(context);

      if (m.status == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', m.data?.token ?? '');
        await prefs.setString('authData', m.data?.authData ?? '');
        LoginState().value = true;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        CloudToast.show(
            m.error?.toString() ?? '登录失败，请重启设备，在登录试试看', context);
      }
    } catch (e) {
      CloudToast.hideLoading(context);
      String errorMsg = '登录失败，请重启设备，在登录试试看';
      if (e is DioException) {
        final map = e.response?.data;
        if (map is Map && map.containsKey('message')) {
          errorMsg = map['message'].toString();
        }
      }
      CloudToast.show(errorMsg, context);
    } finally {
      _isLoggingIn = false;
    }
  }
}
