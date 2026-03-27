import 'package:shared_preferences/shared_preferences.dart';

import '../cloud_model/cloud_version_model.dart';

class AnnouncementManager {
  /// ===== 本地存储 key =====
  static const String _autoShownKey = "announcement_auto_shown";
  static const String _readKey = "announcement_read";

  /// ===============================
  /// 是否需要自动弹（第一次安装）
  /// ===============================
  static Future<bool> shouldAutoShow(CloudVersionModel? model) async {
    if (model?.data == null) return false;
    // 接口控制
    if (model?.data?.show != 1) return false;
    final prefs = await SharedPreferences.getInstance();
    bool hasAutoShown = prefs.getBool(_autoShownKey) ?? false;

    return !hasAutoShown;
  }

  /// 标记已自动弹过
  static Future<void> markAutoShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoShownKey, true);
  }

  /// ===============================
  /// 是否有未读（控制红点）
  /// ===============================
  static Future<bool> hasUnread(Data? data) async {
    if (data == null) return false;

    if (data.show != 1) return false;

    final prefs = await SharedPreferences.getInstance();
    bool hasRead = prefs.getBool(_readKey) ?? false;

    return !hasRead;
  }

  /// 标记已读
  static Future<void> markAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readKey, true);
  }

  /// （可选）清除状态 — 调试用
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoShownKey);
    await prefs.remove(_readKey);
  }
}