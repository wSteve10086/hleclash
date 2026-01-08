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

/// versionIntroduction : "版本更新内容:\n1. 优化无法登录问题. \n2.如果更新提示您手机存在相同版本,请卸载 APP重新安装 "
/// updateAddress : "https://sub.flyyydds.top:21600/client-download/zhuiyun.apk"
/// forcedFlag : 0
/// version : "2.3.1"
/// versionCode : 19
/// title : "配置文件未激活解决方案"
/// content : "\n 由于域名被墙,需要重新登录获取订阅\n 1.APP退出登录\n2.使用 4G 流量打开APP,等十秒在点连接按即可\n3.成功使用在切换wifi"
/// show : 0
/// img_url : ""
/// baseUrl : "https://sub.chasing.sbs:21600"
/// subUrl : "https://sub.chasing.sbs:21600"
/// btnTitle : "查看更多福利"

class Data {
  Data({
    String? versionIntroduction,
    String? updateAddress,
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
  }) {
    _versionIntroduction = versionIntroduction;
    _updateAddress = updateAddress;
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
  }

  Data.fromJson(Map<String, dynamic> json) {
    _versionIntroduction = json['versionIntroduction'] as String?;
    _updateAddress = json['updateAddress'] as String?;
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
  }
  String? _versionIntroduction;
  String? _updateAddress;
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
  Data copyWith({
    String? versionIntroduction,
    String? updateAddress,
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
  }) =>
      Data(
        versionIntroduction: versionIntroduction ?? _versionIntroduction,
        updateAddress: updateAddress ?? _updateAddress,
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
      );
  String? get versionIntroduction => _versionIntroduction;
  String? get updateAddress => _updateAddress;
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['versionIntroduction'] = _versionIntroduction;
    map['updateAddress'] = _updateAddress;
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
    return map;
  }
}
