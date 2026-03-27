import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/profile_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../zhuiyun/cloud_model/CloudVersionStorage.dart';
import 'clash_config.dart';

part 'generated/profile.freezed.dart';
part 'generated/profile.g.dart';

@freezed
abstract class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    @Default(0) int upload,
    @Default(0) int download,
    @Default(0) int total,
    @Default(0) int expire,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$SubscriptionInfoFromJson(json);

  factory SubscriptionInfo.formHString(String? info) {
    if (info == null) return const SubscriptionInfo();
    final list = info.split(';');
    Map<String, int?> map = {};
    for (final i in list) {
      final keyValue = i.trim().split('=');
      map[keyValue[0]] = int.tryParse(keyValue[1]);
    }
    return SubscriptionInfo(
      upload: map['upload'] ?? 0,
      download: map['download'] ?? 0,
      total: map['total'] ?? 0,
      expire: map['expire'] ?? 0,
    );
  }
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? label,
    String? currentGroupName,
    @Default('') String url,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    SubscriptionInfo? subscriptionInfo,
    @Default(true) bool autoUpdate,
    @Default({}) Map<String, String> selectedMap,
    @Default({}) Set<String> unfoldSet,
    @Default(OverrideData()) OverrideData overrideData,
    @Default(Overwrite()) Overwrite overwrite,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isUpdating,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({String? label, String url = ''}) {
    return Profile(
      label: label,
      url: url,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      autoUpdateDuration: defaultUpdateDuration,
    );
  }
}

@freezed
abstract class Overwrite with _$Overwrite {
  const factory Overwrite({
    @Default(OverwriteType.standard) OverwriteType type,
    @Default(StandardOverwrite()) StandardOverwrite standardOverwrite,
    @Default(ScriptOverwrite()) ScriptOverwrite scriptOverwrite,
  }) = _Overwrite;

  factory Overwrite.fromJson(Map<String, Object?> json) =>
      _$OverwriteFromJson(json);
}

@freezed
abstract class StandardOverwrite with _$StandardOverwrite {
  const factory StandardOverwrite({
    @Default([]) List<Rule> addedRules,
    @Default([]) List<String> disabledRuleIds,
  }) = _StandardOverwrite;

  factory StandardOverwrite.fromJson(Map<String, Object?> json) =>
      _$StandardOverwriteFromJson(json);
}

@freezed
abstract class ScriptOverwrite with _$ScriptOverwrite {
  const factory ScriptOverwrite({String? scriptId}) = _ScriptOverwrite;

  factory ScriptOverwrite.fromJson(Map<String, Object?> json) =>
      _$ScriptOverwriteFromJson(json);
}

@freezed
abstract class OverrideData with _$OverrideData {
  const factory OverrideData({
    @Default(false) bool enable,
    @Default(OverrideRule()) OverrideRule rule,
  }) = _OverrideData;

  factory OverrideData.fromJson(Map<String, Object?> json) =>
      _$OverrideDataFromJson(json);
}

@freezed
abstract class OverrideRule with _$OverrideRule {
  const factory OverrideRule({
    @Default(OverrideRuleType.added) OverrideRuleType type,
    @Default([]) List<Rule> overrideRules,
    @Default([]) List<Rule> addedRules,
  }) = _OverrideRule;

  factory OverrideRule.fromJson(Map<String, Object?> json) =>
      _$OverrideRuleFromJson(json);
}

extension OverrideDataExt on OverrideData {
  List<String> get runningRule {
    if (!enable) {
      return [];
    }
    return rule.rules.map((item) => item.value).toList();
  }
}

extension OverrideRuleExt on OverrideRule {
  List<Rule> get rules => switch (type == OverrideRuleType.override) {
    true => overrideRules,
    false => addedRules,
  };

  OverrideRule updateRules(List<Rule> Function(List<Rule> rules) builder) {
    if (type == OverrideRuleType.added) {
      return copyWith(addedRules: builder(addedRules));
    }
    return copyWith(overrideRules: builder(overrideRules));
  }
}

extension ProfilesExt on List<Profile> {
  Profile? getProfile(String? profileId) {
    final index = indexWhere((profile) => profile.id == profileId);
    return index == -1 ? null : this[index];
  }
}

extension ProfileExtension on Profile {
  ProfileType get type =>
      url.isEmpty == true ? ProfileType.file : ProfileType.url;

  bool get realAutoUpdate => url.isEmpty == true ? false : autoUpdate;

  Future<void> checkAndUpdate() async {
    final isExists = await check();
    if (!isExists) {
      if (url.isNotEmpty) {
        await update();
      }
    }
  }

  Future<bool> check() async {
    final profilePath = await appPath.getProfilePath(id);
    return await File(profilePath).exists();
  }

  Future<File> getFile() async {
    final path = await appPath.getProfilePath(id);
    final file = File(path);
    final isExists = await file.exists();
    if (!isExists) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<int> get profileLastModified async {
    final file = await getFile();
    return (await file.lastModified()).microsecondsSinceEpoch;
  }

  Future<Profile> update() async {
    final response = await request.getFileResponseForUrl(url);
    final disposition = response.headers.value('content-disposition');
    final userinfo = response.headers.value('subscription-userinfo');
    return await copyWith(
      label: label ?? utils.getFileNameForDisposition(disposition) ?? id,
      subscriptionInfo: SubscriptionInfo.formHString(userinfo),
    ).saveFile(response.data ?? Uint8List.fromList([]));
  }

  // Future<Profile> saveFile(Uint8List bytes) async {
  //   final message = await coreController.validateConfigFormBytes(bytes);
  //   if (message.isNotEmpty) {
  //     throw message;
  //   }
  //   final file = await getFile();
  //   await Isolate.run(() async {
  //     return await file.writeAsBytes(bytes);
  //   });
  //   return copyWith(lastUpdateDate: DateTime.now());
  //
  // }
  Future<Profile> saveFile(Uint8List bytes) async {
    String config = utf8.decode(bytes);
    final node1 = CloudVersionStorage.instance.model?.data?.nodeName01;
    final node2 = CloudVersionStorage.instance.model?.data?.nodeName02;
    // 取 node3 原始数组，如果为空就初始化为空列表
    final node3 = CloudVersionStorage.instance.model?.data?.nodeName03 != null
        ? List<String>.from(CloudVersionStorage.instance.model!.data!.nodeName03!)
        : <String>[];

    // 追加 node1 和 node2（如果不为空且非重复）
    if (node1 != null && node1.isNotEmpty) {
      node3.add(node1);
    }
    if (node2 != null && node2.isNotEmpty) {
      node3.add(node2);
    }
    // 只有当 node3 有内容才替换配置
    if (node3.isNotEmpty) {
      config = replaceAllProxyServer(
        config,
        newServers: node3,
      );
    }

    // 校验修改后的配置
    final message = await coreController.validateConfig(config);
    if (message.isNotEmpty) {
      throw message;
    }
    final file = await getFile();
    // 放到 isolate 避免卡顿
    await Isolate.run(() async {
      await file.writeAsString(config);
    });

    return copyWith(lastUpdateDate: DateTime.now());
  }

}
