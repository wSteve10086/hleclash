import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:flutter/foundation.dart';
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
  CloudRequest._internal();
  static final CloudRequest _instance = CloudRequest._internal();
  factory CloudRequest() => _instance;

  // version sources
  final String CHECKVERVERSION =
      "https://zyxb.oss-cn-wuhan-lr.aliyuncs.com/fly_checkVersion.txt";
  final String CHECKVERVERSION2 =
      "https://raw.gitcode.com/lishiming123/zzzzzzzzzzzzzzzzyyyyyy/raw/main/fly_checkVersion.txt";
  final String CHECKVERVERSION3 =
      "https://pub-d51a46c1ed05483887d9cbbc4ea8d40a.r2.dev/fly_checkVersion.txt";

  final Dio _dio = Dio(BaseOptions(
    baseUrl: '',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent': browserUa,
      'Accept': '*/*',
      'Connection': 'close',
    },
  ));

  String _baseUrl = '';
  String get baseUrl => _baseUrl;

  static String errorMessage(
    Object error, {
    String fallback = '数据异常',
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'].toString().trim();
        if (msg.isNotEmpty) return msg;
      }
      final msg = error.message?.trim();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

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
        debugPrint("⚠️ 请求重试 ${i + 1}");
      }
    }
    throw Exception("request failed");
  }

  Future<String> _authData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authData') ?? '';
  }

  Future<Options> _authOptions() async {
    return Options(headers: {'Authorization': await _authData()});
  }

  Future<Response<Map<String, dynamic>>> _authedGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _safeRequest(
      () async => _dio.get<Map<String, dynamic>>(
        '$baseUrl$path',
        queryParameters: queryParameters,
        options: await _authOptions(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> _authedPost(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _safeRequest(
      () async => _dio.post<Map<String, dynamic>>(
        '$baseUrl$path',
        queryParameters: queryParameters,
        options: await _authOptions(),
      ),
    );
  }

  Future<void> refreshBaseUrl() async {
    if (_baseUrl.isNotEmpty) return;

    try {
      final model = await fetchVersion();
      CloudVersionStorage.instance.model = model;
      _baseUrl = model.data?.baseUrl ?? '';
      debugPrint('✅ BaseUrl 已更新: $_baseUrl');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseUrl', _baseUrl);
    } catch (e) {
      debugPrint('❌ 刷新 BaseUrl 失败: $e');

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('baseUrl');
      if (cached != null) {
        _baseUrl = cached;
        debugPrint('⚠️ 使用缓存 BaseUrl: $_baseUrl');
      }
    }
  }

  Future<CloudVersionModel> fetchVersion() async {
    final urls = [
      CHECKVERVERSION,
      CHECKVERVERSION2,
      CHECKVERVERSION3,
    ]..shuffle(Random());

    for (final url in urls) {
      try {
        final response = await _safeRequest(() => _dio.get(url));
        debugPrint("👉 请求成功: ${response.realUri}");

        final decrypted = AESUtil.decryptAES(response.data.toString());
        return CloudVersionModel.fromJson(jsonDecode(decrypted));
      } catch (e) {
        debugPrint("❌ 接口失败 $url : $e");
      }
    }

    return getVersionInfo();
  }

  Future<CloudVersionModel> getVersionInfo() async {
    final response = await _safeRequest(() => _dio.get(CHECKVERVERSION3));
    final decrypted = AESUtil.decryptAES(response.data.toString());
    debugPrint("👉 兜底配置 URL: ${response.realUri}");
    return CloudVersionModel.fromJson(jsonDecode(decrypted));
  }

  Future<CloudLoginModel> login({
    required String email,
    required String password,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception("BaseUrl 未初始化，请先调用 refreshBaseUrl()");
    }

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

  Future<CloudSubscribeModel> getSubscribe() async {
    final resp = await _authedGet('/api/v1/user/getSubscribe');
    return CloudSubscribeModel.fromJson(resp.data);
  }

  Future<CloudOrderModel> getOrderList() async {
    final resp = await _authedGet('/api/v1/user/order/fetch');
    return CloudOrderModel.fromJson(resp.data);
  }

  Future<CloudGoodsModel> getGoodsList() async {
    final resp = await _authedGet('/api/v1/user/plan/fetch');
    return CloudGoodsModel.fromJson(resp.data ?? {});
  }

  Future<CloudGoodsDetailsModel> getGoodsDetails(num planId) async {
    final resp = await _authedGet(
      '/api/v1/user/plan/fetch',
      queryParameters: {'id': planId},
    );
    try {
      return CloudGoodsDetailsModel.fromJson(resp.data ?? {});
    } catch (e) {
      debugPrint('getGoodsDetails parse error: $e');
      return CloudGoodsDetailsModel(
        status: 'error',
        message: '商品详情解析失败',
        data: null,
        error: e.toString(),
      );
    }
  }

  Future<CloudGoodsPayMethod> getPayMethod() async {
    final resp = await _authedGet('/api/v1/user/order/getPaymentMethod');
    return CloudGoodsPayMethod.fromJson(resp.data);
  }

  Future<String> getTradeNo(String period, num planId, String code) async {
    final queryParameters = {
      'plan_id': planId,
      'period': period,
      if (code.isNotEmpty) 'coupon_code': code,
    };
    final resp = await _authedPost(
      '/api/v1/user/order/save',
      queryParameters: queryParameters,
    );
    final m = CloudTradeNo.fromJson(resp.data);
    return m.data ?? '';
  }

  Future<CloudPayModel> getPayUrl(String tradeNo, String payMethID) async {
    final resp = await _authedPost(
      '/api/v1/user/order/checkout',
      queryParameters: {'trade_no': tradeNo, 'method': payMethID},
    );
    return CloudPayModel.fromJson(resp.data);
  }

  Future<bool> cancelOrder(String tradeNo) async {
    final resp = await _authedPost(
      '/api/v1/user/order/cancel',
      queryParameters: {'trade_no': tradeNo},
    );
    return CloudCancelOrderModel.fromJson(resp.data ?? {}).data ?? false;
  }

  Future<CloudOrderDetailsModel> getOrderDetails(String tradeNo) async {
    final resp = await _authedGet(
      '/api/v1/user/order/detail',
      queryParameters: {'trade_no': tradeNo},
    );
    return CloudOrderDetailsModel.fromJson(resp.data);
  }

  Future<CloudCouponModel> checkCoupon(String code, num planId) async {
    final resp = await _authedPost(
      '/api/v1/user/coupon/check',
      queryParameters: {'code': code, 'plan_id': planId},
    );
    return CloudCouponModel.fromJson(resp.data ?? {});
  }

  Future<CloudInviteWelfareModel> getInviteWelfare() async {
    final resp = await _authedGet('/api/v1/user/invite/fetch');
    return CloudInviteWelfareModel.fromJson(resp.data ?? {});
  }

  Future<CloudInviteUsersModel> getInviteUsers() async {
    final resp = await _authedGet('/api/v1/user/invite/details');
    return CloudInviteUsersModel.fromJson(resp.data ?? {});
  }

  Future<String> getInviteUrl(String code) async {
    return '$baseUrl/#/register?code=$code';
  }
}