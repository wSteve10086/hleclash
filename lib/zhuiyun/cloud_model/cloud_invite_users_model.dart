
class CloudInviteUsersModel {
  CloudInviteUsersModel({
      List<Data>? data, 
      num? total,}){
    _data = data;
    _total = total;
}

  CloudInviteUsersModel.fromJson(Map<String,dynamic> json) {
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v as Map<String,dynamic>));
      });
    }
    _total = json['total'] as num?;
  }
  List<Data>? _data;
  num? _total;
CloudInviteUsersModel copyWith({  List<Data>? data,
  num? total,
}) => CloudInviteUsersModel(  data: data ?? _data,
  total: total ?? _total,
);
  List<Data>? get data => _data;
  num? get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;
    return map;
  }

}

/// id : 68494
/// order_amount : 800
/// trade_no : "2024040920043767424693502"
/// get_amount : 160
/// created_at : 1712925241

class Data {
  Data({
      num? id, 
      num? orderAmount, 
      String? tradeNo, 
      num? getAmount, 
      num? createdAt,}){
    _id = id;
    _orderAmount = orderAmount;
    _tradeNo = tradeNo;
    _getAmount = getAmount;
    _createdAt = createdAt;
}

  Data.fromJson(Map<String,dynamic> json) {
    _id = json['id'] as num?;
    _orderAmount = json['order_amount']as num?;
    _tradeNo = json['trade_no']as String?;
    _getAmount = json['get_amount']as num?;
    _createdAt = json['created_at']as num?;
  }
  num? _id;
  num? _orderAmount;
  String? _tradeNo;
  num? _getAmount;
  num? _createdAt;
Data copyWith({  num? id,
  num? orderAmount,
  String? tradeNo,
  num? getAmount,
  num? createdAt,
}) => Data(  id: id ?? _id,
  orderAmount: orderAmount ?? _orderAmount,
  tradeNo: tradeNo ?? _tradeNo,
  getAmount: getAmount ?? _getAmount,
  createdAt: createdAt ?? _createdAt,
);
  num? get id => _id;
  num? get orderAmount => _orderAmount;
  String? get tradeNo => _tradeNo;
  num? get getAmount => _getAmount;
  num? get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['order_amount'] = _orderAmount;
    map['trade_no'] = _tradeNo;
    map['get_amount'] = _getAmount;
    map['created_at'] = _createdAt;
    return map;
  }

}
