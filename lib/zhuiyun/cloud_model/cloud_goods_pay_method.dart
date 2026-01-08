/// status : "success"
/// message : "操作成功"
/// data : [{"id":3,"name":"会员支付(若支付不成功, 就用会员支付 N)","payment":"EPay","icon":"https://www.tkcloud.xyz/client-download/jcbb_icon.png","handling_fee_fixed":null,"handling_fee_percent":null},{"id":4,"name":"会员支付 N(最低支付 10 元)","payment":"EPay","icon":null,"handling_fee_fixed":null,"handling_fee_percent":null}]
/// error : null

class CloudGoodsPayMethod {
  CloudGoodsPayMethod({
      String? status, 
      String? message, 
      List<Data>? data, 
      dynamic error,}){
    _status = status;
    _message = message;
    _data = data;
    _error = error;
}

  CloudGoodsPayMethod.fromJson(dynamic json) {
    _status = json['status'] as String?;
    _message = json['message']as String?;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _error = json['error'];
  }
  String? _status;
  String? _message;
  List<Data>? _data;
  dynamic _error;
CloudGoodsPayMethod copyWith({  String? status,
  String? message,
  List<Data>? data,
  dynamic error,
}) => CloudGoodsPayMethod(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
  error: error ?? _error,
);
  String? get status => _status;
  String? get message => _message;
  List<Data>? get data => _data;
  dynamic get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['error'] = _error;
    return map;
  }

}

/// id : 3
/// name : "会员支付(若支付不成功, 就用会员支付 N)"
/// payment : "EPay"
/// icon : "https://www.tkcloud.xyz/client-download/jcbb_icon.png"
/// handling_fee_fixed : null
/// handling_fee_percent : null

class Data {
  Data({
      num? id, 
      String? name, 
      String? payment, 
      String? icon, 
      dynamic handlingFeeFixed, 
      dynamic handlingFeePercent,}){
    _id = id;
    _name = name;
    _payment = payment;
    _icon = icon;
    _handlingFeeFixed = handlingFeeFixed;
    _handlingFeePercent = handlingFeePercent;
}

  Data.fromJson(dynamic json) {
    _id = json['id']as num?;
    _name = json['name']as String?;
    _payment = json['payment']as String?;
    _icon = json['icon']as String?;
    _handlingFeeFixed = json['handling_fee_fixed'];
    _handlingFeePercent = json['handling_fee_percent'];
  }
  num? _id;
  String? _name;
  String? _payment;
  String? _icon;
  dynamic _handlingFeeFixed;
  dynamic _handlingFeePercent;
Data copyWith({  num? id,
  String? name,
  String? payment,
  String? icon,
  dynamic handlingFeeFixed,
  dynamic handlingFeePercent,
}) => Data(  id: id ?? _id,
  name: name ?? _name,
  payment: payment ?? _payment,
  icon: icon ?? _icon,
  handlingFeeFixed: handlingFeeFixed ?? _handlingFeeFixed,
  handlingFeePercent: handlingFeePercent ?? _handlingFeePercent,
);
  num? get id => _id;
  String? get name => _name;
  String? get payment => _payment;
  String? get icon => _icon;
  dynamic get handlingFeeFixed => _handlingFeeFixed;
  dynamic get handlingFeePercent => _handlingFeePercent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['payment'] = _payment;
    map['icon'] = _icon;
    map['handling_fee_fixed'] = _handlingFeeFixed;
    map['handling_fee_percent'] = _handlingFeePercent;
    return map;
  }

}
