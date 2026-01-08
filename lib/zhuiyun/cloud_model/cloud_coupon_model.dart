class CloudCouponModel {
  CloudCouponModel({
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

  CloudCouponModel.fromJson(Map<String, dynamic> json) {
    _status = json['status'] as String?;
    _message = json['message'] as String?;
    _data = json['data'] != null
        ? Data.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  Data? _data;
  dynamic _error;
  CloudCouponModel copyWith({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) =>
      CloudCouponModel(
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

/// id : 4
/// code : "ZY666"
/// name : "机场巴巴老客户专用"
/// type : 2
/// value : 20
/// show : 1
/// limit_use : 1132
/// limit_use_with_user : 10
/// limit_plan_ids : null
/// limit_period : null
/// started_at : 1669907548
/// ended_at : 1722438748
/// created_at : 1676474161
/// updated_at : 1713429175

class Data {
  Data({
    num? id,
    String? code,
    String? name,
    num? type,
    num? value,
    num? show,
    num? limitUse,
    num? limitUseWithUser,
    dynamic limitPlanIds,
    dynamic limitPeriod,
    num? startedAt,
    num? endedAt,
    num? createdAt,
    num? updatedAt,
  }) {
    _id = id;
    _code = code;
    _name = name;
    _type = type;
    _value = value;
    _show = show;
    _limitUse = limitUse;
    _limitUseWithUser = limitUseWithUser;
    _limitPlanIds = limitPlanIds;
    _limitPeriod = limitPeriod;
    _startedAt = startedAt;
    _endedAt = endedAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(Map<String, dynamic> json) {
    _id = json['id'] as num?;
    _code = json['code'] as String?;
    _name = json['name'] as String?;
    _type = json['type'] as num?;
    _value = json['value'] as num?;
    _show = json['show'] as num?;
    _limitUse = json['limit_use'] as num?;
    _limitUseWithUser = json['limit_use_with_user'] as num?;
    _limitPlanIds = json['limit_plan_ids'] as String?;
    _limitPeriod = json['limit_period'] as String?;
    _startedAt = json['started_at'] as num?;
    _endedAt = json['ended_at'] as num?;
    _createdAt = json['created_at'] as num?;
    _updatedAt = json['updated_at'] as num?;
  }
  num? _id;
  String? _code;
  String? _name;
  num? _type;
  num? _value;
  num? _show;
  num? _limitUse;
  num? _limitUseWithUser;
  dynamic _limitPlanIds;
  dynamic _limitPeriod;
  num? _startedAt;
  num? _endedAt;
  num? _createdAt;
  num? _updatedAt;
  Data copyWith({
    num? id,
    String? code,
    String? name,
    num? type,
    num? value,
    num? show,
    num? limitUse,
    num? limitUseWithUser,
    dynamic limitPlanIds,
    dynamic limitPeriod,
    num? startedAt,
    num? endedAt,
    num? createdAt,
    num? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        code: code ?? _code,
        name: name ?? _name,
        type: type ?? _type,
        value: value ?? _value,
        show: show ?? _show,
        limitUse: limitUse ?? _limitUse,
        limitUseWithUser: limitUseWithUser ?? _limitUseWithUser,
        limitPlanIds: limitPlanIds ?? _limitPlanIds,
        limitPeriod: limitPeriod ?? _limitPeriod,
        startedAt: startedAt ?? _startedAt,
        endedAt: endedAt ?? _endedAt,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get code => _code;
  String? get name => _name;
  num? get type => _type;
  num? get value => _value;
  num? get show => _show;
  num? get limitUse => _limitUse;
  num? get limitUseWithUser => _limitUseWithUser;
  dynamic get limitPlanIds => _limitPlanIds;
  dynamic get limitPeriod => _limitPeriod;
  num? get startedAt => _startedAt;
  num? get endedAt => _endedAt;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['type'] = _type;
    map['value'] = _value;
    map['show'] = _show;
    map['limit_use'] = _limitUse;
    map['limit_use_with_user'] = _limitUseWithUser;
    map['limit_plan_ids'] = _limitPlanIds;
    map['limit_period'] = _limitPeriod;
    map['started_at'] = _startedAt;
    map['ended_at'] = _endedAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
