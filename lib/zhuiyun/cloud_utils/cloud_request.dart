import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_cancel_order_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_coupon_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_details_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_goods_pay_method.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_users_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_invite_welfare_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_login_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_order_details_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_order_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_pay_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_send_email_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_subscribe_model.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_trade_no.dart';
import 'package:fl_clash/zhuiyun/cloud_model/cloud_version_model.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_aes_until.dart';
import '../cloud_model/CloudVersionStorage.dart';

class CloudRequest {
  // -------------------- 单例 --------------------
  CloudRequest._internal();
  static final CloudRequest _instance = CloudRequest._internal();
  factory CloudRequest() => _instance;

  // -------------------- 常量 --------------------
  final CHECKVERVERSION =
      "https://zyxb.oss-cn-wuhan-lr.aliyuncs.com/fly_checkVersion.txt";
  final CHECKVERVERSION2 =
      "https://raw.gitcode.com/lishiming123/zzzzzzzzzzzzzzzzyyyyyy/raw/main/fly_checkVersion.txt";
  final CHECKVERVERSION3 =
      "https://pub-d51a46c1ed05483887d9cbbc4ea8d40a.r2.dev/fly_checkVersion.txt";

  // -------------------- Dio --------------------
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent': browserUa,
      'Accept': '*/*',
    },
  ));

  // -------------------- 内存 BaseUrl --------------------
  String _baseUrl = '';

  String get baseUrl => _baseUrl;

  // -------------------- 自动重试方法 --------------------
  Future<Response<T>> _safeRequest<T>(
      Future<Response<T>> Function() request, {
        int retry = 2,
      }) async {
    for (int i = 0; i <= retry; i++) {
      try {
        return await request();
      } catch (e) {
        if (i == retry) rethrow;
        await Future.delayed(const Duration(milliseconds: 800));
        print("⚠️ 请求重试 ${i + 1}");
      }
    }
    throw Exception("request failed");
  }

  // -------------------- 刷新 BaseUrl --------------------
  Future<void> refreshBaseUrl() async {
    if (_baseUrl.isNotEmpty) return;

    try {
      final model = await fetchVersion();
      CloudVersionStorage.instance.model = model;
      _baseUrl = model.data?.baseUrl ?? '';
      print('✅ BaseUrl 已更新: $_baseUrl');

      // 保存到本地缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseUrl', _baseUrl);
    } catch (e) {
      print('❌ 刷新 BaseUrl 失败: $e');

      // 尝试读取本地缓存
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('baseUrl');
      if (cached != null) {
        _baseUrl = cached;
        print('⚠️ 使用缓存 BaseUrl: $_baseUrl');
      }
    }
  }

  // -------------------- 版本接口 --------------------
  Future<CloudVersionModel> fetchVersion() async {
    final urls = [
      CHECKVERVERSION,
      CHECKVERVERSION2,
      CHECKVERVERSION3,
    ]..shuffle(Random());

    for (final url in urls) {
      try {
        final response = await _safeRequest(() => _dio.get(url));
        print("👉 请求成功: ${response.realUri}");

        final decrypted = AESUtil.decryptAES(response.data.toString());
        return CloudVersionModel.fromJson(jsonDecode(decrypted));
      } catch (e) {
        print("❌ 接口失败 $url : $e");
      }
    }

    // 所有接口失败
    return getVersionInfo();
  }

  Future<CloudVersionModel> getVersionInfo() async {
    final response = await _safeRequest(() => _dio.get(CHECKVERVERSION3));
    final decrypted = AESUtil.decryptAES(response.data.toString());
    print("👉 兜底配置 URL: ${response.realUri}");
    return CloudVersionModel.fromJson(jsonDecode(decrypted));
  }

  // -------------------- 用户相关 --------------------
  Future<CloudLoginModel> login({
    required String email,
    required String password,
  }) async {
    if (_baseUrl.isEmpty) throw Exception("BaseUrl 未初始化，请先调用 refreshBaseUrl()");

    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/passport/auth/login',
      queryParameters: {'email': email, 'password': password},
    ));
    return CloudLoginModel.fromJson(resp.data ?? {});
  }

  Future<bool> sendEmail(String email) async {
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/passport/comm/sendEmailVerify',
      queryParameters: {'email': email},
    ));
    return CloudSendEmailModel.fromJson(resp.data ?? {}).data ?? false;
  }

  Future<CloudLoginModel> register({
    required String email,
    required String password,
    required String code,
    required String inviterCode,
  }) async {
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/passport/auth/register',
      queryParameters: {
        'email': email,
        'password': password,
        'email_code': code,
        'invite_code': inviterCode,
      },
    ));
    return CloudLoginModel.fromJson(resp.data ?? {});
  }

  Future<bool> resetPwd({
    required String email,
    required String password,
    required String code,
  }) async {
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/passport/auth/forget',
      queryParameters: {
        'email': email,
        'password': password,
        'email_code': code,
      },
    ));
    return CloudSendEmailModel.fromJson(resp.data ?? {}).data ?? false;
  }

  // -------------------- 订阅 / 订单 / 商品 --------------------
  Future<CloudSubscribeModel> getSubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/getSubscribe',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudSubscribeModel.fromJson(resp.data);
  }

  Future<CloudOrderModel> getOrderList() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/fetch',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudOrderModel.fromJson(resp.data);
  }

  Future<CloudGoodsModel> getGoodsList() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/plan/fetch',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudGoodsModel.fromJson(resp.data ?? {});
  }

  Future<CloudGoodsDetailsModel> getGoodsDetails(num planId) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/plan/fetch',
      queryParameters: {'id': planId},
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudGoodsDetailsModel.fromJson(resp.data ?? {});
  }

  Future<CloudGoodsPayMethod> getPayMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/getPaymentMethod',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudGoodsPayMethod.fromJson(resp.data);
  }

  Future<String> getTradeNo(String period, num planId, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final queryParameters = {
      'plan_id': planId,
      'period': period,
      if (code.isNotEmpty) 'coupon_code': code,
    };
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/save',
      queryParameters: queryParameters,
      options: Options(headers: {'Authorization': authData}),
    ));
    final m = CloudTradeNo.fromJson(resp.data);
    return m.data ?? '';
  }

  Future<CloudPayModel> getPayUrl(String tradeNo, String payMethID) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/checkout',
      queryParameters: {'trade_no': tradeNo, 'method': payMethID},
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudPayModel.fromJson(resp.data);
  }

  Future<bool> cancelOrder(String tradeNo) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/cancel',
      queryParameters: {'trade_no': tradeNo},
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudCancelOrderModel.fromJson(resp.data ?? {}).data ?? false;
  }

  Future<CloudOrderDetailsModel> getOrderDetails(String tradeNo) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/order/detail',
      queryParameters: {'trade_no': tradeNo},
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudOrderDetailsModel.fromJson(resp.data);
  }

  Future<CloudCouponModel> checkCoupon(String code, num planId) async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.post<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/coupon/check',
      queryParameters: {'code': code, 'plan_id': planId},
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudCouponModel.fromJson(resp.data ?? {});
  }

  Future<CloudInviteWelfareModel> getInviteWelfare() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/invite/fetch',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudInviteWelfareModel.fromJson(resp.data ?? {});
  }

  Future<CloudInviteUsersModel> getInviteUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData') ?? '';
    final resp = await _safeRequest(() => _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/user/invite/details',
      options: Options(headers: {'Authorization': authData}),
    ));
    return CloudInviteUsersModel.fromJson(resp.data ?? {});
  }

  Future<String> getInviteUrl(String code) async {
    return '$baseUrl/#/register?code=$code';
  }
}