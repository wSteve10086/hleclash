class CloudInviteWelfareModel {
  CloudInviteWelfareModel({
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

  CloudInviteWelfareModel.fromJson(Map<String, dynamic> json) {
    _status = json['status'] as String?;
    _message = json['message'] as String?;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  Data? _data;
  dynamic _error;
  CloudInviteWelfareModel copyWith({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) =>
      CloudInviteWelfareModel(
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

/// codes : [{"user_id":123,"code":"w0KRKu6w","pv":0,"status":0,"created_at":1680074880,"updated_at":1680074880},{"user_id":123,"code":"m4k47oXF","pv":0,"status":0,"created_at":1680163660,"updated_at":1680163660},{"user_id":123,"code":"QSfS6EWT","pv":0,"status":0,"created_at":1685070319,"updated_at":1685070319},{"user_id":123,"code":"tnY3igIp","pv":0,"status":0,"created_at":1685686009,"updated_at":1685686009},{"user_id":123,"code":"fvNBPF5y","pv":0,"status":0,"created_at":1685785639,"updated_at":1685785639}]
/// stat : [22,10536,0,20,1200]

class Data {
  Data({
    List<Codes>? codes,
    List<num>? stat,
  }) {
    _codes = codes;
    _stat = stat;
  }

  Data.fromJson(dynamic json) {
    if (json['codes'] != null) {
      _codes = [];
      json['codes'].forEach((v) {
        _codes?.add(Codes.fromJson(v as Map<String, dynamic>));
      });
    }
    _stat =
        json['stat'] != null ? (json['stat'] as List<dynamic>).cast<num>() : [];
  }
  List<Codes>? _codes;
  List<num>? _stat;
  Data copyWith({
    List<Codes>? codes,
    List<num>? stat,
  }) =>
      Data(
        codes: codes ?? _codes,
        stat: stat ?? _stat,
      );
  List<Codes>? get codes => _codes;
  List<num>? get stat => _stat;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_codes != null) {
      map['codes'] = _codes?.map((v) => v.toJson()).toList();
    }
    map['stat'] = _stat;
    return map;
  }
}

/// user_id : 123
/// code : "w0KRKu6w"
/// pv : 0
/// status : 0
/// created_at : 1680074880
/// updated_at : 1680074880

class Codes {
  Codes({
    num? userId,
    String? code,
    num? pv,
    num? status,
    num? createdAt,
    num? updatedAt,
  }) {
    _userId = userId;
    _code = code;
    _pv = pv;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Codes.fromJson(Map<String, dynamic> json) {
    _userId = json['user_id'] as num?;
    _code = json['code'] as String?;
    _pv = json['pv'] as num?;
    _status = json['status'] as num?;
    _createdAt = json['created_at'] as num?;
    _updatedAt = json['updated_at'] as num?;
  }
  num? _userId;
  String? _code;
  num? _pv;
  num? _status;
  num? _createdAt;
  num? _updatedAt;
  Codes copyWith({
    num? userId,
    String? code,
    num? pv,
    num? status,
    num? createdAt,
    num? updatedAt,
  }) =>
      Codes(
        userId: userId ?? _userId,
        code: code ?? _code,
        pv: pv ?? _pv,
        status: status ?? _status,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get userId => _userId;
  String? get code => _code;
  num? get pv => _pv;
  num? get status => _status;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _userId;
    map['code'] = _code;
    map['pv'] = _pv;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
