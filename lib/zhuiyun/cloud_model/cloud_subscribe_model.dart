

class CloudSubscribeModel {
  CloudSubscribeModel({
      String? status,
      String? message,
      Data? data,
      dynamic error,}){
    _status = status;
    _message = message;
    _data = data;
    _error = error;
}

  CloudSubscribeModel.fromJson(dynamic json) {
    _status = json['status']as String?;
    _message = json['message']as String?;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  Data? _data;
  dynamic _error;
CloudSubscribeModel copyWith({  String? status,
  String? message,
  Data? data,
  dynamic error,
}) => CloudSubscribeModel(  status: status ?? _status,
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
      map['data'] = _data!.toJson();
    }
    map['error'] = _error;
    return map;
  }

}

/// plan_id : 18
/// token : "84e4e6f812a1eef48339e971437486ae"
/// expired_at : 1727602363
/// u : 626168035
/// d : 22928315582
/// transfer_enable : 289910292480
/// email : "9764302012@gmail.com"
/// uuid : "6beb2486-9e10-41cb-b20f-446cf7919f8a"
/// plan : {"id":18,"group_id":1,"transfer_enable":270,"name":"套餐 A-季付(老用户专享)","speed_limit":null,"show":0,"sort":8,"renew":1,"content":"①  270G流量 90 天有效期&#x2714;<br>\n ② 高速VIP1节点通用&#x2714;<br>\n ③ 1000Mbps峰值速率&#x2714;<br>\n ④ 线上客服快速响应&#x2714;<br>\n ⑤ 解锁部分流媒体(Netflix、Disney)&#x2714;<br>\n ⑥ 限制五台设备&#x2714;<br>","month_price":null,"quarter_price":1900,"half_year_price":null,"year_price":null,"two_year_price":null,"three_year_price":null,"onetime_price":null,"reset_price":null,"reset_traffic_method":2,"capacity_limit":null,"created_at":1691550917,"updated_at":1738462198}
/// subscribe_url : "https://sub.chasing.sbs:21600/api/v1/client/subscribe?token=84e4e6f812a1eef48339e971437486ae"
/// reset_day : null

class Data {
  Data({
      num? planId,
      String? token,
      num? expiredAt,
      num? u,
      num? d,
      num? transferEnable,
      String? email,
      String? uuid,
      Plan? plan,
      String? subscribeUrl,
      dynamic resetDay,}){
    _planId = planId;
    _token = token;
    _expiredAt = expiredAt;
    _u = u;
    _d = d;
    _transferEnable = transferEnable;
    _email = email;
    _uuid = uuid;
    _plan = plan;
    _subscribeUrl = subscribeUrl;
    _resetDay = resetDay;
}

  Data.fromJson(dynamic json) {
    _planId = json['plan_id'] as num?;
    _token = json['token']as String?;
    _expiredAt = json['expired_at']as num?;
    _u = json['u']as num?;
    _d = json['d']as num?;
    _transferEnable = json['transfer_enable']as num?;
    _email = json['email']as String?;
    _uuid = json['uuid']as String?;
    _plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
    _subscribeUrl = json['subscribe_url']as String?;
    _resetDay = json['reset_day'];
  }
  num? _planId;
  String? _token;
  num? _expiredAt;
  num? _u;
  num? _d;
  num? _transferEnable;
  String? _email;
  String? _uuid;
  Plan? _plan;
  String? _subscribeUrl;
  dynamic _resetDay;
Data copyWith({  num? planId,
  String? token,
  num? expiredAt,
  num? u,
  num? d,
  num? transferEnable,
  String? email,
  String? uuid,
  Plan? plan,
  String? subscribeUrl,
  dynamic resetDay,
}) => Data(  planId: planId ?? _planId,
  token: token ?? _token,
  expiredAt: expiredAt ?? _expiredAt,
  u: u ?? _u,
  d: d ?? _d,
  transferEnable: transferEnable ?? _transferEnable,
  email: email ?? _email,
  uuid: uuid ?? _uuid,
  plan: plan ?? _plan,
  subscribeUrl: subscribeUrl ?? _subscribeUrl,
  resetDay: resetDay ?? _resetDay,
);
  num? get planId => _planId;
  String? get token => _token;
  num? get expiredAt => _expiredAt;
  num? get u => _u;
  num? get d => _d;
  num? get transferEnable => _transferEnable;
  String? get email => _email;
  String? get uuid => _uuid;
  Plan? get plan => _plan;
  String? get subscribeUrl => _subscribeUrl;
  dynamic get resetDay => _resetDay;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['plan_id'] = _planId;
    map['token'] = _token;
    map['expired_at'] = _expiredAt;
    map['u'] = _u;
    map['d'] = _d;
    map['transfer_enable'] = _transferEnable;
    map['email'] = _email;
    map['uuid'] = _uuid;
    if (_plan != null) {
      map['plan'] = _plan!.toJson();
    }
    map['subscribe_url'] = _subscribeUrl;
    map['reset_day'] = _resetDay;
    return map;
  }

}

/// id : 18
/// group_id : 1
/// transfer_enable : 270
/// name : "套餐 A-季付(老用户专享)"
/// speed_limit : null
/// show : 0
/// sort : 8
/// renew : 1
/// content : "①  270G流量 90 天有效期&#x2714;<br>\n ② 高速VIP1节点通用&#x2714;<br>\n ③ 1000Mbps峰值速率&#x2714;<br>\n ④ 线上客服快速响应&#x2714;<br>\n ⑤ 解锁部分流媒体(Netflix、Disney)&#x2714;<br>\n ⑥ 限制五台设备&#x2714;<br>"
/// month_price : null
/// quarter_price : 1900
/// half_year_price : null
/// year_price : null
/// two_year_price : null
/// three_year_price : null
/// onetime_price : null
/// reset_price : null
/// reset_traffic_method : 2
/// capacity_limit : null
/// created_at : 1691550917
/// updated_at : 1738462198

class Plan {
  Plan({
      num? id,
      num? groupId,
      num? transferEnable,
      String? name,
      dynamic speedLimit, 
      num? show,
      num? sort,
      num? renew,
      String? content,
      dynamic monthPrice, 
      num? quarterPrice,
      dynamic halfYearPrice, 
      dynamic yearPrice, 
      dynamic twoYearPrice, 
      dynamic threeYearPrice, 
      dynamic onetimePrice, 
      dynamic resetPrice, 
      num? resetTrafficMethod,
      dynamic capacityLimit, 
      num? createdAt,
      num? updatedAt,}){
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

  Plan.fromJson(dynamic json) {
    _id = json['id']as num?;
    _groupId = json['group_id']as num?;
    _transferEnable = json['transfer_enable']as num?;
    _name = json['name']as String?;
    _speedLimit = json['speed_limit'];
    _show = json['show']as num?;
    _sort = json['sort']as num?;
    _renew = json['renew']as num?;
    _content = json['content']as String?;
    _monthPrice = json['month_price'];
    _quarterPrice = json['quarter_price']as num?;
    _halfYearPrice = json['half_year_price'];
    _yearPrice = json['year_price'];
    _twoYearPrice = json['two_year_price'];
    _threeYearPrice = json['three_year_price'];
    _onetimePrice = json['onetime_price'];
    _resetPrice = json['reset_price'];
    _resetTrafficMethod = json['reset_traffic_method']as num?;
    _capacityLimit = json['capacity_limit'];
    _createdAt = json['created_at']as num?;
    _updatedAt = json['updated_at']as num?;
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
  dynamic _monthPrice;
  num? _quarterPrice;
  dynamic _halfYearPrice;
  dynamic _yearPrice;
  dynamic _twoYearPrice;
  dynamic _threeYearPrice;
  dynamic _onetimePrice;
  dynamic _resetPrice;
  num? _resetTrafficMethod;
  dynamic _capacityLimit;
  num? _createdAt;
  num? _updatedAt;
Plan copyWith({  num? id,
  num? groupId,
  num? transferEnable,
  String? name,
  dynamic speedLimit,
  num? show,
  num? sort,
  num? renew,
  String? content,
  dynamic monthPrice,
  num? quarterPrice,
  dynamic halfYearPrice,
  dynamic yearPrice,
  dynamic twoYearPrice,
  dynamic threeYearPrice,
  dynamic onetimePrice,
  dynamic resetPrice,
  num? resetTrafficMethod,
  dynamic capacityLimit,
  num? createdAt,
  num? updatedAt,
}) => Plan(  id: id ?? _id,
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
  dynamic get monthPrice => _monthPrice;
  num? get quarterPrice => _quarterPrice;
  dynamic get halfYearPrice => _halfYearPrice;
  dynamic get yearPrice => _yearPrice;
  dynamic get twoYearPrice => _twoYearPrice;
  dynamic get threeYearPrice => _threeYearPrice;
  dynamic get onetimePrice => _onetimePrice;
  dynamic get resetPrice => _resetPrice;
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
