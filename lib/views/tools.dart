import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/quickjs/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' show dirname, join;
import 'package:shared_preferences/shared_preferences.dart';

import '../zhuiyun/cloud_login/cloud_login_page.dart';
import '../zhuiyun/cloud_mine/cloud_invite/cloud_invite_page.dart';
import '../zhuiyun/cloud_mine/cloud_order/cloud_order_page.dart';
import '../zhuiyun/cloud_model/CloudVersionStorage.dart';
import '../zhuiyun/cloud_utils/cloud_colors.dart';
import '../zhuiyun/cloud_utils/cloud_login_state.dart';
import '../zhuiyun/cloud_utils/cloud_request.dart';
import '../zhuiyun/cloud_utils/cloud_toast.dart';
import 'backup_and_recovery.dart';
import 'config/advanced.dart';
import 'developer.dart';
import 'theme.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: OpenDelegate(widget: navigationItem.builder(context)),
    );
  }

  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return Column(
      children: [
        for (final navigationItem in navigationItems) ...[
          _buildNavigationMenuItem(navigationItem),
          navigationItems.last != navigationItem
              ? const Divider(height: 0)
              : Container(),
        ],
      ],
    );
  }

  List<Widget> _getMineList() {
    return generateSection(
      title: '我的',
      items: [
        ListTile(
          leading: const Icon(Icons.book_online),
          title: const Text('我的订单'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CloudOrderPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('邀请返利'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CloudInvitePage(),
              ),
            );
          },
        ),
      ],
    );
  }


  List<Widget> _getOtherList(bool enableDeveloperMode) {
    return generateSection(
      title: context.appLocalizations.other,
      items: [
        _DisclaimerItem(),
        if (enableDeveloperMode) _DeveloperItem(),
        _InfoItem(),
        ListItem(
          leading: const Icon(Icons.update),
          title: Text(appLocalizations.checkUpdate),
          onTap: () {
            _checkUpdate();
          },
        ),
        ListItem(
          leading: const Icon(Icons.wifi_channel_sharp),
          title: const Text("Telegram频道"),
          onTap: () {
            globalState.openUrl(
              "https://t.me/t.me/fastflyclub",
            );
          },
          // trailing: const Icon(Icons.launch),
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('退出登录'),
          onTap: () async {
            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.setString('token', '');
            prefs.setString('authData', '');
            prefs.setString('vip_list', '');
            prefs.setString('invite', '');
            prefs.setString('expired', '');
            LoginState().value = false;
            CloudVersionStorage.instance.clear();
              globalState.appController.updateStatus(false);
            final navigationState = ref.watch(navigationStateProvider);
            final navigationItems = navigationState.navigationItems;
            globalState.appController.toPage(
              navigationItems[0].label,
            );
            deleteAllProfiles();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CloudLoginPage(),
              ),
            );
          },
        ),
      ],
    );
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
    final beforeUpdateTime =
        currentProfile.lastUpdateDate?.millisecondsSinceEpoch;
    await appController.updateProfile(currentProfile);
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

  /// 退出登录删除所有配置
  Future<void> deleteAllProfiles() async {
    final appController = globalState.appController;
    /// 1️⃣ 取 profiles 快照（避免边删边遍历）
    final profiles = List<Profile>.from(globalState.config.profiles);
    /// 2️⃣ 删除所有 profiles
    for (final profile in profiles) {
      final profilePath = await appPath.getProfilePath(profile.id);
      appController.clearEffect(profilePath);
    }
  }




  List<Widget> _getSettingList() {
    return generateSection(
      title: context.appLocalizations.settings,
      items: [
        const _LocaleItem(),
        const _ThemeItem(),
        const _BackupItem(),
        if (system.isDesktop) const _HotkeyItem(),
        if (system.isWindows) const _LoopbackItem(),
        if (system.isAndroid) const _AccessItem(),
        const _ConfigItem(),
        const _AdvancedConfigItem(),
        const _SettingItem(),
      ],
    );
  }

  void _checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;
    CloudRequest().getVersionInfo().then((value) async {
      if (version != value.data?.version && value.data?.forcedFlag == 1) {
        var vList = value.data?.versionIntroduction?.split('\n') ?? [];
        var downloadUrl = value.data?.updateAddress ?? '';
        _cloudDialog('版本更新', vList, downloadUrl);
      } else {
        CloudToast.show('已是最新版本', context);
      }
    }).catchError((e) {});
  }

  void _cloudDialog(String title, List<String> vList, String downloadUrl) {
    showDialog(
        context: context,
        builder: (BuildContext c) {
          return StatefulBuilder(
              builder: (BuildContext ctx, StateSetter updateState) => Center(
                child: Container(
                  height: 310,
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CloudColors.c40455D,
                        CloudColors.c242738,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 21,
                          color: CloudColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 160,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                                vList.length,
                                    (index) => Text(
                                  vList[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CloudColors.white,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   behavior: HitTestBehavior.translucent,
                      //   onTap: () async {
                      //     if (downloadUrl.isEmpty) {
                      //       Navigator.of(c).pop();
                      //       return;
                      //     }
                      //
                      //     //  CloudToast.loading( context);
                      //     OtaUpdate()
                      //         .execute(downloadUrl,
                      //         destinationFilename: 'last.apk')
                      //         .listen(
                      //           (OtaEvent event) {
                      //         if (event.status == OtaStatus.DOWNLOADING) {
                      //           _btnTitle = '已下载${event.value}%';
                      //         }
                      //         if (event.status == OtaStatus.INSTALLING) {
                      //           _btnTitle = '安装中...';
                      //         }
                      //         updateState(() {});
                      //
                      //         if (event.status != OtaStatus.DOWNLOADING) {
                      //           // CloudToast.hideLoading( context);
                      //           Navigator.of(c).pop();
                      //         }
                      //       },
                      //     );
                      //   },
                      //   child: Container(
                      //     height: 44,
                      //     width: 230,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(22),
                      //       gradient: const LinearGradient(
                      //         begin: Alignment.centerLeft,
                      //         end: Alignment.centerRight,
                      //         colors: [
                      //           CloudColors.c63483D,
                      //           CloudColors.cBA987A,
                      //         ],
                      //       ),
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         title == '版本更新' ? _btnTitle : '我知道了',
                      //         style: const TextStyle(
                      //           color: CloudColors.white,
                      //           fontSize: 15,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(a: state.locale, b: state.developerMode),
      ),
    );
    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return Column(
            children: [
              ListHeader(title: context.appLocalizations.more),
              _buildNavigationMenu(state.navigationItems),
            ],
          );
        },
      ),
      ..._getMineList(),
      ..._getSettingList(),
      ..._getOtherList(vm2.b),
    ];
    return CommonScaffold(
      title: context.appLocalizations.tools,
      body: ListView.builder(
        key: toolsStoreKey,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
        padding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}



class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  String _getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final subTitle = locale ?? context.appLocalizations.defaultText;
    final currentLocale = utils.getLocaleForString(locale);
    return ListItem<Locale?>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(context.appLocalizations.language),
      subtitle: Text(Intl.message(subTitle)),
      delegate: OptionsDelegate(
        title: context.appLocalizations.language,
        options: [null, ...AppLocalizations.delegate.supportedLocales],
        onChanged: (Locale? locale) {
          ref
              .read(appSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(locale: locale?.toString()),
              );
        },
        textBuilder: (locale) => _getLocaleString(locale),
        value: currentLocale,
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.style),
      title: Text(context.appLocalizations.theme),
      subtitle: Text(context.appLocalizations.themeDesc),
      delegate: OpenDelegate(widget: const ThemeView()),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.cloud_sync),
      title: Text(context.appLocalizations.backupAndRecovery),
      subtitle: Text(context.appLocalizations.backupAndRecoveryDesc),
      delegate: OpenDelegate(widget: const BackupAndRecovery()),
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.keyboard),
      title: Text(context.appLocalizations.hotkeyManagement),
      subtitle: Text(context.appLocalizations.hotkeyManagementDesc),
      delegate: OpenDelegate(widget: const HotKeyView()),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.lock),
      title: Text(context.appLocalizations.loopback),
      subtitle: Text(context.appLocalizations.loopbackDesc),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.view_list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      delegate: OpenDelegate(widget: const AccessView()),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.edit),
      title: Text(context.appLocalizations.basicConfig),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      delegate: OpenDelegate(widget: const ConfigView()),
    );
  }
}

class _AdvancedConfigItem extends StatelessWidget {
  const _AdvancedConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.build),
      title: Text(context.appLocalizations.advancedConfig),
      subtitle: Text(context.appLocalizations.advancedConfigDesc),
      delegate: OpenDelegate(widget: const AdvancedConfigView()),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.settings),
      title: Text(context.appLocalizations.application),
      subtitle: Text(context.appLocalizations.applicationDesc),
      delegate: OpenDelegate(widget: const ApplicationSettingView()),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.gavel),
      title: Text(context.appLocalizations.disclaimer),
      onTap: () async {
        final isDisclaimerAccepted = await globalState.appController
            .showDisclaimer();
        if (!isDisclaimerAccepted) {
          globalState.appController.handleExit();
        }
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.info),
      title: Text(context.appLocalizations.about),
      delegate: OpenDelegate(widget: const AboutView()),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.developer_board),
      title: Text(context.appLocalizations.developerMode),
      delegate: OpenDelegate(widget: const DeveloperView()),
    );
  }


}
