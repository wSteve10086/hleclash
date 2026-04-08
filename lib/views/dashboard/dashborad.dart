import 'dart:io';
import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/quickjs/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/profile.dart';
import '../../zhuiyun/cloud_model/CloudVersionStorage.dart';
import '../../zhuiyun/cloud_model/cloud_version_model.dart';
import '../../zhuiyun/cloud_update/cloud_download_webpage.dart';
import '../../zhuiyun/cloud_utils/announcement_manager.dart';
import '../../zhuiyun/cloud_utils/cloud_colors.dart';
import '../../zhuiyun/cloud_utils/cloud_login_state.dart';
import '../../zhuiyun/cloud_utils/cloud_request.dart';
import '../../zhuiyun/cloud_utils/cloud_toast.dart';
import '../../zhuiyun/cloud_vip/cloud_vip_page.dart';
import 'widgets/start_button.dart';
import '../../zhuiyun/cloud_state/vip_state.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String _btnTitle = '立即更新';
  final key = GlobalKey<SuperGridState>();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);
  String? _announcementSyncKey;
  bool _dashboardAnnouncementUnread = false;
  bool _dashboardShow1Read = false;
  final Set<String> _announcementDotClearedSigs = <String>{};

  String _cloudPlatformDownloadUrl(Data? data) {
    if (data == null) return '';
    if (Platform.isAndroid) return data.updateAddress_android ?? '';
    if (Platform.isIOS) return data.updateAddress_ios ?? '';
    if (Platform.isMacOS) return data.updateAddress_mac ?? '';
    if (Platform.isWindows) return data.updateAddress_windows ?? '';
    return data.updateAddress ?? '';
  }

  bool _cloudRemoteVersionIsNewer(String currentVersion, String? remoteRaw) {
    if (remoteRaw == null || remoteRaw.isEmpty) return false;
    final remote = remoteRaw.trim().replaceFirst(RegExp(r'^v'), '');
    final current = currentVersion.trim().replaceFirst(RegExp(r'^v'), '');
    try {
      return _compareVersions(current, remote) < 0;
    } catch (_) {
      return false;
    }
  }

  int _compareVersions(String current, String remote) {
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final r = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLen = c.length > r.length ? c.length : r.length;
    for (var i = 0; i < maxLen; i++) {
      final cv = i < c.length ? c[i] : 0;
      final rv = i < r.length ? r[i] : 0;
      if (cv != rv) return cv.compareTo(rv);
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    LoginState()
      ..setLoadVip(_loadVip)
      ..loadVipIfNeeded(); // 只会执行一次
    if (Platform.isAndroid) {
      Future.delayed(const Duration(seconds: 2), getVersionInfo);
    }
  }

  @override
  dispose() {
    _isEditNotifier.dispose();
    _addedWidgetsNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, _) {
        return builder(isEdit);
      },
    );
  }

  Future<void> _handleConnection() async {
    final coreStatus = ref.read(coreStatusProvider);
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final tip = coreStatus == CoreStatus.connected
        ? appLocalizations.forceRestartCoreTip
        : appLocalizations.restartCoreTip;
    final res = await globalState.showMessage(message: TextSpan(text: tip));
    if (res != true) {
      return;
    }
    globalState.appController.restartCore();
  }

  List<Widget> _buildActions(bool isEdit) {
    return [
      if (!isEdit)
        Consumer(
          builder: (_, ref, _) {
            final coreStatus = ref.watch(coreStatusProvider);
            return Tooltip(
              message: appLocalizations.coreStatus,
              child: FadeScaleBox(
                alignment: Alignment.centerRight,
                child: coreStatus == CoreStatus.connected
                    ? IconButton.filled(
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: switch (Theme.brightnessOf(
                      context,
                    )) {
                      Brightness.light =>
                      context.colorScheme.onSurfaceVariant,
                      Brightness.dark =>
                      context.colorScheme.onPrimaryFixedVariant,
                    },
                  ),
                  onPressed: _handleConnection,
                  icon: Icon(Icons.check, fontWeight: FontWeight.w900),
                )
                    : FilledButton.icon(
                  key: ValueKey(coreStatus),
                  onPressed: _handleConnection,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: switch (coreStatus) {
                      CoreStatus.connecting => null,
                      CoreStatus.connected => Colors.greenAccent,
                      CoreStatus.disconnected =>
                      context.colorScheme.error,
                    },
                    foregroundColor: switch (coreStatus) {
                      CoreStatus.connecting => null,
                      CoreStatus.connected => switch (Theme.brightnessOf(
                        context,
                      )) {
                        Brightness.light =>
                        context.colorScheme.onSurfaceVariant,
                        Brightness.dark => null,
                      },
                      CoreStatus.disconnected =>
                      context.colorScheme.onError,
                    },
                  ),
                  icon: SizedBox(
                    height: globalState.measure.bodyMediumHeight,
                    width: globalState.measure.bodyMediumHeight,
                    child: switch (coreStatus) {
                      CoreStatus.connecting => Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: context.colorScheme.onPrimary,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      CoreStatus.connected => Icon(
                        Icons.check_sharp,
                        fontWeight: FontWeight.w900,
                      ),
                      CoreStatus.disconnected => Icon(
                        Icons.restart_alt_sharp,
                        fontWeight: FontWeight.w900,
                      ),
                    },
                  ),
                  label: Text(switch (coreStatus) {
                    CoreStatus.connecting => appLocalizations.connecting,
                    CoreStatus.connected => appLocalizations.connected,
                    CoreStatus.disconnected =>
                    appLocalizations.disconnected,
                  }),
                ),
              ),
            );
          },
        ),
      if (isEdit)
        ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, addedChildren, child) {
            if (addedChildren.isEmpty) {
              return Container();
            }
            return child!;
          },
          child: IconButton(
            onPressed: () {
              _showAddWidgetsModal();
            },
            icon: Icon(Icons.add_circle),
          ),
        ),

      FadeRotationScaleBox(
        child: TextButton(
          key: ValueKey<bool>(isEdit),
          onPressed: _handlebGoShoppPage,
          child: Text('购买套餐'),
        ),
      ),

      // FadeRotationScaleBox(
      //   child: isEdit
      //       ? IconButton(
      //     key: ValueKey(true),
      //     icon: Icon(Icons.save, key: ValueKey('save-icon')),
      //     onPressed: _handleUpdateIsEdit,
      //   )
      //       : IconButton(
      //     key: ValueKey(false),
      //     icon: Icon(Icons.edit, key: ValueKey('edit-icon')),
      //     onPressed: _handleUpdateIsEdit,
      //   ),
      // ),


    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_, type) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return AdaptiveSheetScaffold(
              type: type,
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem) {
                  key.currentState?.handleAdd(gridItem);
                },
              ),
              title: appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  /// 新增功能
  Future<void> _handlebGoShoppPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CloudVipPage(),
      ),
    );
  }


  Future<void> _handleUpdateIsEdit() async {
    if (_isEditNotifier.value == true) {
      await _handleSave();
    }
    _isEditNotifier.value = !_isEditNotifier.value;
  }


  Future<void> _handleSave() async {
    final currentState = key.currentState;
    if (currentState == null) {
      return;
    }
    if (mounted) {
      await currentState.isTransformCompleter;
      final dashboardWidgets = currentState.children
          .map((item) => DashboardWidget.getDashboardWidget(item))
          .toList();
      ref
          .read(appSettingProvider.notifier)
          .updateState(
            (state) => state.copyWith(dashboardWidgets: dashboardWidgets),
      );
    }
  }


  /// 加载订阅
  Future<void> _loadVip({bool force = false}) async {
    try {
      final value = await CloudRequest().getSubscribe();
      final data = value.data;

      final used = (data?.u ?? 0) + (data?.d ?? 0);
      final total = data?.transferEnable ?? 0;
      final progress = total == 0 ? 0.0 : used / total;

      final expiredAt = data?.expiredAt;
      final expired = expiredAt != null &&
          expiredAt.toInt() * 1000 < DateTime.now().millisecondsSinceEpoch;
      final transferFull = used >= total;

      final vipState =
      (data?.planId == null || expired || transferFull)
          ? VipState.abnormal
          : VipState.normal;

      ref.read(vipProvider.notifier).state = VipModel(
        vipState: vipState,
        planName: data?.plan?.name ?? '',
        expiredAt: getExpireAt(expiredAt),
        transferUsed: getTransfer(used),
        totalTransfer: getTransfer(total),
        progress: progress.clamp(0.0, 1.0),
        email: data?.email ?? '',
      );

      // 尝试更新 profile
      final baseUrl =
          CloudVersionStorage.instance.model?.data?.subUrl ??
          CloudRequest().baseUrl;
      final originUrl = data?.subscribeUrl ?? '';
      if (originUrl.isNotEmpty) {
        final replacedUrl = originUrl.replaceFirst(
          RegExp(r"^https://[^/]+"),
          baseUrl,
        );
        await canUpdateProfile(replacedUrl);
      }
    } catch (_) {
      ref.read(vipProvider.notifier).state =
          VipModel(vipState: VipState.normal);
    }

  }



  Future<bool> canUpdateProfile(String subscribeUrl) async {
    final appController = globalState.appController;
    /// 当前 profile（正确来源）
    Profile? currentProfile;
    final currentProfileId = globalState.config.currentProfileId;

    if (currentProfileId != null) {
      currentProfile = globalState.config.profiles
          .firstWhereOrNull((p) => p.id == currentProfileId);
    }

    /// 1️⃣ 没有 profile → 添加
    if (currentProfile == null) {
      if (subscribeUrl.isEmpty) {
        return false;
      }

      await appController.addProfileFormURL(subscribeUrl);

      // 未启动 → 直接应用
      if (!globalState.isStart) {
        await appController.applyProfile(silence: true);
      }

      return false;
    }

    /// 2️⃣ 已有 profile → 更新
    // 换账号后 API 的订阅链接会变；仍用旧 url 拉取则文件不会更新
    final profileToSync = subscribeUrl.isNotEmpty &&
            currentProfile.url != subscribeUrl
        ? currentProfile.copyWith(url: subscribeUrl)
        : currentProfile;
    if (profileToSync.url != currentProfile.url) {
      appController.setProfile(profileToSync);
    }

    final beforeUpdateTime =
        profileToSync.lastUpdateDate?.millisecondsSinceEpoch;

    await appController.updateProfile(profileToSync);

    /// 3️⃣ 是否真的发生更新
    final updatedProfileId = globalState.config.currentProfileId;
    if (updatedProfileId == null) return false;

    final updatedProfile = globalState.config.profiles
        .firstWhereOrNull((p) => p.id == updatedProfileId);

    final isProfileChanged =
        updatedProfile?.lastUpdateDate?.millisecondsSinceEpoch !=
            beforeUpdateTime;

    /// ⚠️ 不要手动 apply（updateProfile 内部已处理）
    return isProfileChanged;
  }


  String getExpireAt(num? timestamp) {
    if (timestamp == null) return '不限时长';
    if (timestamp.toInt() * 1000 < DateTime.now().millisecondsSinceEpoch) return '套餐已过期，请重新购买';
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000));
  }

  String getTransfer(num t) {
    if (t < 1024) return '${t.toStringAsFixed(2)}KB';
    if (t < 1024 * 1024 * 1024) return '${(t / 1024 / 1024).toStringAsFixed(2)}MB';
    if (t < 1024 * 1024 * 1024 * 1024) return '${(t / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    return '${(t / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)}TB';
  }

  /// 获取版本信息：仅处理版本更新（不再在这里弹公告）
  void getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;
      final data = CloudVersionStorage.instance.model?.data;
      if (data == null) return;

      final localBelowRemote =
          _cloudRemoteVersionIsNewer(localVersion, data.version);
      if (!localBelowRemote) return;

      final flag = data.forcedFlag;
      final vList = data.versionIntroduction?.split('\n') ?? [];
      final downloadUrl = _cloudPlatformDownloadUrl(data);

      if (flag == 2) {
        if (!mounted) return;
        _cloudDialog(
          '版本更新',
          vList,
          downloadUrl,
          localVersion: localVersion,
          remoteVersion: data.version ?? localVersion,
          isForceUpdate: true,
        );
        return;
      }
      if (flag == 1) {
        if (!mounted) return;
        _cloudDialog(
          '有新版本啦',
          vList,
          downloadUrl,
          localVersion: localVersion,
          remoteVersion: data.version ?? localVersion,
          isForceUpdate: false,
        );
      }
    } catch (e, st) {
      debugPrint('getVersionInfo error: $e\n$st');
    }
  }

  Future<void> _cloudDialog(
    String title,
    List<String> vList,
    String downloadUrl, {
    required String localVersion,
    required String remoteVersion,
    bool isForceUpdate = false,
  }) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (BuildContext c) {
        return PopScope(
          canPop: !isForceUpdate,
          child: StatefulBuilder(
            builder: (BuildContext ctx, StateSetter updateState) => Center(
              child: Container(
                height: 310,
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [CloudColors.c40455D, CloudColors.c242738],
                  ),
                ),
                child: Column(
                  children: [
                  Text(title, style: const TextStyle(fontSize: 21, color: CloudColors.white, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(
                    '最新版本：$remoteVersion  当前版本：$localVersion',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CloudColors.cA4ADBD,
                    ),
                  ),
                  Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: vList.map((line) => Text(line, style: const TextStyle(fontSize: 14, color: CloudColors.white))).toList(),
                      ),
                    ),
                  ),
                  if (!isForceUpdate)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => Navigator.of(c).pop(),
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: CloudColors.cA4ADBD),
                              ),
                              child: const Text(
                                '稍后再说',
                                style: TextStyle(color: CloudColors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              if (downloadUrl.isEmpty) {
                                CloudToast.show('更新地址异常，请联系客服处理', context);
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdateDownloadPage(
                                    version: version,
                                    updateLogs: vList,
                                    downloadUrl: downloadUrl,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [CloudColors.c63483D, CloudColors.cBA987A],
                                ),
                              ),
                              child: const Text(
                                '立即更新',
                                style: TextStyle(color: CloudColors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        if (downloadUrl.isEmpty) {
                          CloudToast.show('更新地址异常，请联系客服处理', context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateDownloadPage(
                              version: version,
                              updateLogs: vList,
                              downloadUrl: downloadUrl,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        width: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [CloudColors.c63483D, CloudColors.cBA987A],
                          ),
                        ),
                        child: Center(
                          child: Text(_btnTitle, style: const TextStyle(color: CloudColors.white, fontSize: 15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasAnnouncementPayload(Data? data) {
    if (data == null) return false;
    final t = data.title?.trim() ?? '';
    final c = data.content?.trim() ?? '';
    final img = data.imgUrl?.trim() ?? '';
    return t.isNotEmpty || c.isNotEmpty || img.isNotEmpty;
  }

  String _dashboardAnnouncementStripTitle(Data data) {
    final t = data.title?.trim() ?? '';
    if (t.isEmpty) return '官方公告';
    return '官方公告：$t';
  }

  bool _dashboardAnnouncementBarVisible(Data data) {
    if (!_hasAnnouncementPayload(data)) return false;
    final n = data.show ?? 0;
    if (n == 0) return false;
    if (n == 1) return !_dashboardShow1Read;
    return n > 1;
  }

  void _syncDashboardAnnouncementState(Data? data) {
    if (!mounted) return;
    if (data == null || (data.show ?? 0) == 0 || !_hasAnnouncementPayload(data)) {
      if (_announcementSyncKey != null || _dashboardAnnouncementUnread || _dashboardShow1Read) {
        setState(() {
          _announcementSyncKey = null;
          _dashboardAnnouncementUnread = false;
          _dashboardShow1Read = false;
        });
      }
      return;
    }
    final n = data.show ?? 0;
    final sig = AnnouncementManager.contentSignature(data);
    final key = '$sig|$n';
    if (key == _announcementSyncKey) return;
    _announcementSyncKey = key;
    if (n == 1) {
      AnnouncementManager.isDashboardAnnouncementRead(data).then((read) {
        if (!mounted || _announcementSyncKey != key) return;
        setState(() {
          _dashboardShow1Read = read;
          _dashboardAnnouncementUnread = !read;
        });
      });
    } else if (n > 1) {
      setState(() {
        _dashboardShow1Read = false;
        _dashboardAnnouncementUnread = !_announcementDotClearedSigs.contains(sig);
      });
    }
  }

  Future<void> _showDashboardAnnouncementDialog(CloudVersionModel model) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(model.data?.title ?? '公告'),
          content: SingleChildScrollView(
            child: Text(model.data?.content ?? ''),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final imgUrl = model.data?.imgUrl?.trim() ?? '';
                if (imgUrl.isNotEmpty) {
                  globalState.openUrl(imgUrl);
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(model.data?.btnTitle ?? '关闭'),
            ),
          ],
        );
      },
    );
    final d = model.data;
    final n = d?.show ?? 0;
    if (d != null && n == 1) {
      await AnnouncementManager.markDashboardAnnouncementRead(d);
      if (mounted) {
        setState(() {
          _dashboardShow1Read = true;
          _dashboardAnnouncementUnread = false;
        });
      }
    } else if (d != null && n > 1) {
      final sig = AnnouncementManager.contentSignature(d);
      if (mounted) {
        setState(() {
          _announcementDotClearedSigs.add(sig);
          _dashboardAnnouncementUnread = false;
        });
      }
    }
  }

  Widget _buildAnnouncementTopStrip(CloudVersionModel? model) {
    final data = model?.data;
    if (data == null || !_dashboardAnnouncementBarVisible(data)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (model != null) {
              _showDashboardAnnouncementDialog(model);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (_dashboardAnnouncementUnread)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dashboardAnnouncementStripTitle(data),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 主体界面
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    /// 动态列数
    final columns = max(
      4 * ((dashboardState.contentWidth / 280).ceil()),
      8,
    );

    final spacing = 14.ap;

    /// 当前平台下已添加的 widgets
    final children = dashboardState.dashboardWidgets
        .where(
          (item) => item.platforms.contains(
        SupportPlatform.currentPlatform,
      ),
    )
        .map((item) => item.widget)
        .toList();

    /// 计算「未添加的 widgets」（帧结束后，避免 build 里改状态）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _addedWidgetsNotifier.value = DashboardWidget.values
          .where(
            (item) =>
        !children.contains(item.widget) &&
            item.platforms.contains(
              SupportPlatform.currentPlatform,
            ),
      )
          .map((item) => item.widget)
          .toList();
    });
    final version = CloudVersionStorage.instance.model;
    final announcementData = version?.data;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDashboardAnnouncementState(announcementData);
    });
    final vip = ref.watch(vipProvider);
    return _buildIsEdit(
          (isEdit) => CommonScaffold(
        title: appLocalizations.dashboard,
        actions: _buildActions(isEdit),
        floatingActionButton: const StartButton(),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAnnouncementTopStrip(version),

                ShopDetailSection(
                  planName: vip.planName,
                  expiredAt: vip.expiredAt,
                  transferUsed: vip.transferUsed,
                  totalTransfer: vip.totalTransfer,
                  progress: vip.progress,
                ),
                // ShopDetailSection(
                //   planName: _planName,
                //   expiredAt: _expiredAt,
                //   transferUsed: _transfer,
                //   totalTransfer: _allTransfer,
                //   progress: _progress,
                //
                // ),
                const SizedBox(height: 16),

                /// 🧩 Dashboard 内容
                isEdit
                    ? SystemBackBlock(
                  child: CommonPopScope(
                    child: SuperGrid(
                      key: key,
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      children: children,
                      onUpdate: () {
                        _handleSave();
                      },
                    ),
                    onPop: (context) {
                      _handleUpdateIsEdit();
                      return false;
                    },
                  ),
                )
                    : Grid(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  children: children,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
              builder: (child) {
                return _AddedContainer(
                  onAdd: () {
                    onAdd(item);
                  },
                  child: child,
                );
              },
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class ShopDetailSection extends StatelessWidget {
  final String planName;
  final String expiredAt;
  final String transferUsed;
  final String totalTransfer;
  final double progress;
  final String? subscribeUrl; // 订阅地址
  final VoidCallback? onUpdate; // 可选自定义回调

  ShopDetailSection({
    super.key,
    required this.planName,
    required this.expiredAt,
    required this.transferUsed,
    required this.totalTransfer,
    required this.progress,
    this.subscribeUrl,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 72;
    return Card(
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(planName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text('到期时间: $expiredAt', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text('已使用 $transferUsed / 总流量 $totalTransfer', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 5,
                        width: width,
                        decoration: BoxDecoration(
                          color: CloudColors.cA4ADBD,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Container(
                        height: 5,
                        width: width * progress,
                        decoration: BoxDecoration(
                          color: CloudColors.c2D79FB,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _AddedContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  @override
  State<_AddedContainer> createState() => _AddedContainerState();
}

class _AddedContainerState extends State<_AddedContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_AddedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {}
  }

  Future<void> _handleAdd() async {
    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: widget.child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                iconSize: 20,
                padding: EdgeInsets.all(2),
                onPressed: _handleAdd,
                icon: Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
