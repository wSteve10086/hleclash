import 'package:shared_preferences/shared_preferences.dart';

import '../cloud_model/cloud_version_model.dart';

/// 登录页公告：
/// - [Data.show] == 1：同一则公告（标题+正文等签名）进入登录页时自动弹一次，并展示右上角「公告」入口。
/// - [Data.show] == 0：不自动弹、隐藏公告入口。
class AnnouncementManager {
  AnnouncementManager._();

  static const String _autoShownKeyPrefix = 'announcement_auto_shown_';
  static const String _dashboardReadPrefix = 'dashboard_announcement_read_';

  /// 仅按公告文案与按钮/配图区分，同一内容只自动弹一次（与 [Data.show]、版本号无关）。
  static String _signature(Data? data) {
    if (data == null) return 'empty';
    final raw = [
      data.title ?? '',
      data.content ?? '',
      data.btnTitle ?? '',
      data.imgUrl ?? '',
    ].join('|');
    return raw.hashCode.toString();
  }

  /// 与 [_signature] 一致，供外部判断「是否为同一则公告」。
  static String contentSignature(Data? data) => _signature(data);

  /// 仪表盘公告：当前这条是否在本地已标为已读。
  static Future<bool> isDashboardAnnouncementRead(Data? data) async {
    if (data == null) return true;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_dashboardReadPrefix${_signature(data)}';
    return prefs.getBool(key) ?? false;
  }

  /// 仪表盘 [Data.show] == 1：有有效内容且本地未标记已读则为未读（红点 + 展示条）。
  static Future<bool> isDashboardAnnouncementUnread(Data? data) async {
    if (data == null) return false;
    if ((data.show ?? 0) != 1) return false;
    final t = data.title?.trim() ?? '';
    final c = data.content?.trim() ?? '';
    final img = data.imgUrl?.trim() ?? '';
    if (t.isEmpty && c.isEmpty && img.isEmpty) return false;
    return !(await isDashboardAnnouncementRead(data));
  }

  static Future<void> markDashboardAnnouncementRead(Data? data) async {
    if (data == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_dashboardReadPrefix${_signature(data)}';
    await prefs.setBool(key, true);
  }

  static Future<bool> shouldAutoShow(Data? data) async {
    if (data == null) return false;
    if ((data.show ?? 0) != 1) return false;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_autoShownKeyPrefix${_signature(data)}';
    final hasAutoShown = prefs.getBool(key) ?? false;
    return !hasAutoShown;
  }

  static Future<void> markAutoShown(Data? data) async {
    if (data == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_autoShownKeyPrefix${_signature(data)}';
    await prefs.setBool(key, true);
  }
}
