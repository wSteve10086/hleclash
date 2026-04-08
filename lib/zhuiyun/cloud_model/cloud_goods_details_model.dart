class CloudGoodsDetailsModel {
  CloudGoodsDetailsModel({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) {
    _status = status;
    _message = message;
    _data = data;
    _error = error;
  }

  CloudGoodsDetailsModel.fromJson(Map<String, dynamic> json) {
    _status = json['status']?.toString();
    _message = json['message']?.toString();
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      _data = Data.fromJson(rawData);
    } else if (rawData is Map) {
      _data = Data.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List && rawData.isNotEmpty) {
      final first = rawData.first;
      if (first is Map<String, dynamic>) {
        _data = Data.fromJson(first);
      } else if (first is Map) {
        _data = Data.fromJson(Map<String, dynamic>.from(first));
      } else {
        _data = null;
      }
    } else {
      _data = null;
    }
    _error = json['error'];
  }
  String? _status;
  String? _message;
  Data? _data;
  dynamic _error;
  CloudGoodsDetailsModel copyWith({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) =>
      CloudGoodsDetailsModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
        error: error ?? _error,
      );
  String? get status => _status;
  String? get message => _message;
  Data? get data => _data;
  dynamic get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['error'] = _error;
    return map;
  }
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v.trim());
  return null;
}

/// id : 40
/// group_id : 1
/// transfer_enable : 270
/// name : "套餐 A-季付"
/// speed_limit : null
/// show : 1
/// sort : 21
/// renew : 1
/// content : "①  270G流量 90 天有效期&#x2714;<br>\n ② 高速VIP1节点通用&#x2714;<br>\n ③ 1000Mbps峰值速率&#x2714;<br>\n ④ 线上客服快速响应&#x2714;<br>\n ⑤ 解锁部分流媒体(Netflix、Disney)&#x2714;<br>\n ⑥ 限制五台设备&#x2714;<br>"
/// month_price : null
/// quarter_price : 2100
/// half_year_price : null
/// year_price : null
/// two_year_price : null
/// three_year_price : null
/// onetime_price : null
/// reset_price : null
/// reset_traffic_method : 2
/// capacity_limit : null
/// created_at : 1691550917
/// updated_at : 1738461583

class Data {
  Data({
    num? id,
    num? groupId,
    num? transferEnable,
    String? name,
    dynamic speedLimit,
    num? show,
    num? sort,
    num? renew,
    String? content,
    num? monthPrice,
    num? quarterPrice,
    num? halfYearPrice,
    num? yearPrice,
    num? twoYearPrice,
    num? threeYearPrice,
    num? onetimePrice,
    num? resetPrice,
    num? resetTrafficMethod,
    dynamic capacityLimit,
    num? createdAt,
    num? updatedAt,
  }) {
    _id = id;
    _groupId = groupId;
    _transferEnable = transferEnable;
    _name = name;
    _speedLimit = speedLimit;
    _show = show;
    _sort = sort;
    _renew = renew;
    _content = content;
    _monthPrice = monthPrice;
    _quarterPrice = quarterPrice;
    _halfYearPrice = halfYearPrice;
    _yearPrice = yearPrice;
    _twoYearPrice = twoYearPrice;
    _threeYearPrice = threeYearPrice;
    _onetimePrice = onetimePrice;
    _resetPrice = resetPrice;
    _resetTrafficMethod = resetTrafficMethod;
    _capacityLimit = capacityLimit;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    if (json is! Map) return;
    _id = _asNum(json['id']);
    _groupId = _asNum(json['group_id']);
    _transferEnable = _asNum(json['transfer_enable']);
    _name = json['name']?.toString();
    _speedLimit = _asNum(json['speed_limit']);
    _show = _asNum(json['show']);
    _sort = _asNum(json['sort']);
    _renew = _asNum(json['renew']);
    _content = json['content']?.toString();
    _monthPrice = _asNum(json['month_price']);
    _quarterPrice = _asNum(json['quarter_price']);
    _halfYearPrice = _asNum(json['half_year_price']);
    _yearPrice = _asNum(json['year_price']);
    _twoYearPrice = _asNum(json['two_year_price']);
    _threeYearPrice = _asNum(json['three_year_price']);
    _onetimePrice = _asNum(json['onetime_price']);
    _resetPrice = _asNum(json['reset_price']);
    _resetTrafficMethod = _asNum(json['reset_traffic_method']);
    _capacityLimit = json['capacity_limit'];
    _createdAt = _asNum(json['created_at']);
    _updatedAt = _asNum(json['updated_at']);
  }
  num? _id;
  num? _groupId;
  num? _transferEnable;
  String? _name;
  dynamic _speedLimit;
  num? _show;
  num? _sort;
  num? _renew;
  String? _content;
  num? _monthPrice;
  num? _quarterPrice;
  num? _halfYearPrice;
  num? _yearPrice;
  num? _twoYearPrice;
  num? _threeYearPrice;
  num? _onetimePrice;
  num? _resetPrice;
  num? _resetTrafficMethod;
  dynamic _capacityLimit;
  num? _createdAt;
  num? _updatedAt;
  Data copyWith({
    num? id,
    num? groupId,
    num? transferEnable,
    String? name,
    dynamic speedLimit,
    num? show,
    num? sort,
    num? renew,
    String? content,
    num? monthPrice,
    num? quarterPrice,
    num? halfYearPrice,
    num? yearPrice,
    num? twoYearPrice,
    num? threeYearPrice,
    num? onetimePrice,
    num? resetPrice,
    num? resetTrafficMethod,
    dynamic capacityLimit,
    num? createdAt,
    num? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        groupId: groupId ?? _groupId,
        transferEnable: transferEnable ?? _transferEnable,
        name: name ?? _name,
        speedLimit: speedLimit ?? _speedLimit,
        show: show ?? _show,
        sort: sort ?? _sort,
        renew: renew ?? _renew,
        content: content ?? _content,
        monthPrice: monthPrice ?? _monthPrice,
        quarterPrice: quarterPrice ?? _quarterPrice,
        halfYearPrice: halfYearPrice ?? _halfYearPrice,
        yearPrice: yearPrice ?? _yearPrice,
        twoYearPrice: twoYearPrice ?? _twoYearPrice,
        threeYearPrice: threeYearPrice ?? _threeYearPrice,
        onetimePrice: onetimePrice ?? _onetimePrice,
        resetPrice: resetPrice ?? _resetPrice,
        resetTrafficMethod: resetTrafficMethod ?? _resetTrafficMethod,
        capacityLimit: capacityLimit ?? _capacityLimit,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  num? get groupId => _groupId;
  num? get transferEnable => _transferEnable;
  String? get name => _name;
  dynamic get speedLimit => _speedLimit;
  num? get show => _show;
  num? get sort => _sort;
  num? get renew => _renew;
  String? get content => _content;
  num? get monthPrice => _monthPrice;
  num? get quarterPrice => _quarterPrice;
  num? get halfYearPrice => _halfYearPrice;
  num? get yearPrice => _yearPrice;
  num? get twoYearPrice => _twoYearPrice;
  num? get threeYearPrice => _threeYearPrice;
  num? get onetimePrice => _onetimePrice;
  num? get resetPrice => _resetPrice;
  num? get resetTrafficMethod => _resetTrafficMethod;
  dynamic get capacityLimit => _capacityLimit;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['group_id'] = _groupId;
    map['transfer_enable'] = _transferEnable;
    map['name'] = _name;
    map['speed_limit'] = _speedLimit;
    map['show'] = _show;
    map['sort'] = _sort;
    map['renew'] = _renew;
    map['content'] = _content;
    map['month_price'] = _monthPrice;
    map['quarter_price'] = _quarterPrice;
    map['half_year_price'] = _halfYearPrice;
    map['year_price'] = _yearPrice;
    map['two_year_price'] = _twoYearPrice;
    map['three_year_price'] = _threeYearPrice;
    map['onetime_price'] = _onetimePrice;
    map['reset_price'] = _resetPrice;
    map['reset_traffic_method'] = _resetTrafficMethod;
    map['capacity_limit'] = _capacityLimit;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
