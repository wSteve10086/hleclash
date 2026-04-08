import 'dart:io';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_customer_service/cloud_customer_service_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_customer_service/customer_service_config.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_register/cloud_register_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/cloud_reset_password/cloud_reset_password_page.dart';
import 'package:fl_clash/zhuiyun/cloud_login/widgets/cloud_auth_header.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_login_state.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_request.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
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
  final CloudVersionModel? _announcementData = CloudVersionStorage.instance.model;
  bool get _showAnnouncementEntry => (_announcementData?.data?.show ?? 0) == 1;

  bool get _isEmailEmpty => _emailController.text.isEmpty;
  bool get _isPasswordEmpty => _pwdController.text.isEmpty;
  bool get _canSubmit =>
      _emailController.text.trim().isNotEmpty &&
      _pwdController.text.trim().isNotEmpty &&
      !_isLoggingIn;

  @override
  void initState() {
    super.initState();
    _initAnnouncement();
  }

  Future<void> _initAnnouncement() async {
    try {
      final data = _announcementData?.data;
      if (data == null) return;
      if (await AnnouncementManager.shouldAutoShow(data)) {
        if (!mounted) return;
        await _showAnnouncementDialog(_announcementData!);
        if (!mounted) return;
        await AnnouncementManager.markAutoShown(data);
      }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 50,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (_announcementData != null) {
            _showAnnouncementDialog(_announcementData!);
          }
        },
        child: Row(
          children: [
            Icon(
              Icons.volume_up,
              size: 22,
              color: colorScheme.onSurface,
            ),
            SizedBox(width: 4),
            Text(
              '公告',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// ===== 公告弹窗 =====
  Future<void> _showAnnouncementDialog(CloudVersionModel model) async {
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

  }


  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      floatingActionButton:_buildServiceButton(),
      body: Stack(
        children: [
          _buildBody(context),
          if (_showAnnouncementEntry) _buildAnnouncementIcon(),
        ],
      ),

    );
  }


  /// ===== 原页面UI =====
  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _hideKeyboard(context),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 42),
              child: Column(
                children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: CloudAuthHeader(
              title: 'FastFly',
              subtitle: '极速连接，稳定在线',
              titleStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                height: 1.1,
              ),
              subtitleStyle: TextStyle(
                color: CloudColors.muted(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                  child: CloudThemeAsset(
                    Assets.images.iconClear.path,
                    width: 16,
                    height: 16,
                    tintInLight: true,
                    tintInDark: true,
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
                  child: CloudThemeAsset(
                    _obscure
                        ? Assets.images.iconEyeClosed.path
                        : Assets.images.iconEyeOpened.path,
                    width: 20,
                    height: 20,
                    tintInLight: true,
                    tintInDark: true,
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
            onTap: _canSubmit ? () => _login(context) : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _canSubmit ? 1 : 0.55,
              child: Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
              ),
              child: Center(
                child: Text(
                  '登录',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 15,
                  ),
                ),
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
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '忘记密码',
                style: TextStyle(fontSize: 13, color: CloudColors.muted(context)),
              ),
            ),
          ),
          const SizedBox(height: 26),
          // 创建账户
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudRegisterPage()),
            ),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '创建账户',
                style: TextStyle(fontSize: 13, color: CloudColors.link(context)),
              ),
            ),
          ),
          const SizedBox(height: 6),
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
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                '永久跳转网站:fastfly.club',
                style: TextStyle(
                  fontSize: 13,
                  color: CloudColors.link(context),
                  decoration: TextDecoration.underline,
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
    );
  }

  /// ===== 客服按钮 =====
  Widget _buildServiceButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      child: const Text('客服'),
      onPressed: () async {
        if (Platform.isMacOS || Platform.isWindows) {
          try {
            final webView = await WebviewWindow.create(
              configuration: CreateConfiguration(
                windowHeight: 680,
                windowWidth: 580,
                title: '客服',
                titleBarTopPadding: Platform.isMacOS ? 20 : 0,
              ),
            );
            webView.launch(getCustomerServiceUrl());
          } catch (_) {
            if (!mounted) return;
            CloudToast.show('无法打开客服窗口', context);
          }
        } else {
          if (!mounted) return;
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHighest.withOpacity(0.32),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: (_) => setState(() {}),
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          focusedBorder: _inputBorder(colorScheme.primary.withOpacity(0.9)),
          disabledBorder: _inputBorder(),
          errorBorder: _inputBorder(CloudColors.error(context)),
          focusedErrorBorder: _inputBorder(CloudColors.error(context)),
          enabledBorder: _inputBorder(),
          border: _inputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  InputBorder _inputBorder([Color color = CloudColors.transparent]) =>
      InputBorder.none;

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
      if (!mounted) return;
      CloudToast.hideLoading(context);

      if (m.status == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', m.data?.token ?? '');
        await prefs.setString('authData', m.data?.authData ?? '');
        // 换账号登录后须重新拉订阅；否则 loadVipIfNeeded 认为已加载会跳过
        LoginState().reset();
        LoginState().value = true;
        if (!mounted) return;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        if (!mounted) return;
        CloudToast.show(
            m.error?.toString() ?? '登录失败，请重启设备，在登录试试看', context);
      }
    } catch (e) {
      if (!mounted) return;
      CloudToast.hideLoading(context);
      final errorMsg = CloudRequest.errorMessage(
        e,
        fallback: '登录失败，请重启设备，在登录试试看',
      );
      if (!mounted) return;
      CloudToast.show(errorMsg, context);
    } finally {
      _isLoggingIn = false;
    }
  }
}
