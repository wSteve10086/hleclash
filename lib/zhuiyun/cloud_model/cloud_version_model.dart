class CloudVersionModel {
  CloudVersionModel({
    Data? data,
  }) {
    _data = data;
  }

  CloudVersionModel.fromJson(Map<String, dynamic> json) {
    _data = json['data'] != null
        ? Data.fromJson(json['data'] as Map<String, dynamic>)
        : null;
  }

  Data? _data;

  CloudVersionModel copyWith({
    Data? data,
  }) =>
      CloudVersionModel(
        data: data ?? _data,
      );

  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_data != null) {
      map['data'] = _data!.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    String? versionIntroduction,
    String? updateAddress,
    String? updateAddress_android,
    String? updateAddress_ios,
    String? updateAddress_mac,
    String? updateAddress_windows,
    num? forcedFlag,
    String? version,
    num? versionCode,
    String? title,
    String? content,
    num? show,
    String? imgUrl,
    String? baseUrl,
    String? subUrl,
    String? btnTitle,
    String? nodeName01,
    String? nodeName02,
    List<String>? nodeName03,
  }) {
    _versionIntroduction = versionIntroduction;
    _updateAddress = updateAddress;
    _updateAddress_android = updateAddress_android;
    _updateAddress_ios = updateAddress_ios;
    _updateAddress_mac = updateAddress_mac;
    _updateAddress_windows = updateAddress_windows;
    _forcedFlag = forcedFlag;
    _version = version;
    _versionCode = versionCode;
    _title = title;
    _content = content;
    _show = show;
    _imgUrl = imgUrl;
    _baseUrl = baseUrl;
    _subUrl = subUrl;
    _btnTitle = btnTitle;
    _nodeName01 = nodeName01;
    _nodeName02 = nodeName02;
    _nodeName03 = nodeName03;
  }

  Data.fromJson(Map<String, dynamic> json) {
    _versionIntroduction = json['versionIntroduction'] as String?;
    _updateAddress = json['updateAddress'] as String?;
    _updateAddress_android = json['updateAddress_android'] as String?;
    _updateAddress_ios = json['updateAddress_ios'] as String?;
    _updateAddress_mac = json['updateAddress_mac'] as String?;
    _updateAddress_windows = json['updateAddress_windows'] as String?;
    _forcedFlag = json['forcedFlag'] as num?;
    _version = json['version'] as String?;
    _versionCode = json['versionCode'] as num?;
    _title = json['title'] as String?;
    _content = json['content'] as String?;
    _show = json['show'] as num?;
    _imgUrl = json['img_url'] as String?;
    _baseUrl = json['baseUrl'] as String?;
    _subUrl = json['subUrl'] as String?;
    _btnTitle = json['btnTitle'] as String?;
    _nodeName01 = json['nodeName01'] as String?;
    _nodeName02 = json['nodeName02'] as String?;
    _nodeName03 =
        (json['nodeName03'] as List?)?.map((e) => e.toString()).toList();
  }

  String? _versionIntroduction;
  String? _updateAddress;
  String? _updateAddress_android;
  String? _updateAddress_ios;
  String? _updateAddress_mac;
  String? _updateAddress_windows;
  num? _forcedFlag;
  String? _version;
  num? _versionCode;
  String? _title;
  String? _content;
  num? _show;
  String? _imgUrl;
  String? _baseUrl;
  String? _subUrl;
  String? _btnTitle;
  String? _nodeName01;
  String? _nodeName02;
  List<String>? _nodeName03;

  Data copyWith({
    String? versionIntroduction,
    String? updateAddress,
    String? updateAddress_android,
    String? updateAddress_ios,
    String? updateAddress_mac,
    String? updateAddress_windows,
    num? forcedFlag,
    String? version,
    num? versionCode,
    String? title,
    String? content,
    num? show,
    String? imgUrl,
    String? baseUrl,
    String? subUrl,
    String? btnTitle,
    String? nodeName01,
    String? nodeName02,
    List<String>? nodeName03,
  }) =>
      Data(
        versionIntroduction: versionIntroduction ?? _versionIntroduction,
        updateAddress: updateAddress ?? _updateAddress,
        updateAddress_android:
        updateAddress_android ?? _updateAddress_android,
        updateAddress_ios: updateAddress_ios ?? _updateAddress_ios,
        updateAddress_mac: updateAddress_mac ?? _updateAddress_mac,
        updateAddress_windows:
        updateAddress_windows ?? _updateAddress_windows,
        forcedFlag: forcedFlag ?? _forcedFlag,
        version: version ?? _version,
        versionCode: versionCode ?? _versionCode,
        title: title ?? _title,
        content: content ?? _content,
        show: show ?? _show,
        imgUrl: imgUrl ?? _imgUrl,
        baseUrl: baseUrl ?? _baseUrl,
        subUrl: subUrl ?? _subUrl,
        btnTitle: btnTitle ?? _btnTitle,
        nodeName01: nodeName01 ?? _nodeName01,
        nodeName02: nodeName02 ?? _nodeName02,
        nodeName03: nodeName03 ?? _nodeName03,
      );

  String? get versionIntroduction => _versionIntroduction;
  String? get updateAddress => _updateAddress;
  String? get updateAddress_android => _updateAddress_android;
  String? get updateAddress_ios => _updateAddress_ios;
  String? get updateAddress_mac => _updateAddress_mac;
  String? get updateAddress_windows => _updateAddress_windows;
  num? get forcedFlag => _forcedFlag;
  String? get version => _version;
  num? get versionCode => _versionCode;
  String? get title => _title;
  String? get content => _content;
  num? get show => _show;
  String? get imgUrl => _imgUrl;
  String? get baseUrl => _baseUrl;
  String? get subUrl => _subUrl;
  String? get btnTitle => _btnTitle;
  String? get nodeName01 => _nodeName01;
  String? get nodeName02 => _nodeName02;
  List<String>? get nodeName03 => _nodeName03;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['versionIntroduction'] = _versionIntroduction;
    map['updateAddress'] = _updateAddress;
    map['updateAddress_android'] = _updateAddress_android;
    map['updateAddress_ios'] = _updateAddress_ios;
    map['updateAddress_mac'] = _updateAddress_mac;
    map['updateAddress_windows'] = _updateAddress_windows;
    map['forcedFlag'] = _forcedFlag;
    map['version'] = _version;
    map['versionCode'] = _versionCode;
    map['title'] = _title;
    map['content'] = _content;
    map['show'] = _show;
    map['img_url'] = _imgUrl;
    map['baseUrl'] = _baseUrl;
    map['subUrl'] = _subUrl;
    map['btnTitle'] = _btnTitle;
    map['nodeName01'] = _nodeName01;
    map['nodeName02'] = _nodeName02;
    map['nodeName03'] = _nodeName03;

    return map;
  }
}