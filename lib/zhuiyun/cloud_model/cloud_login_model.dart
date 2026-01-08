class CloudLoginModel {
  CloudLoginModel({
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

  CloudLoginModel.fromJson(Map<String, dynamic> json) {
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
  CloudLoginModel copyWith({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) =>
      CloudLoginModel(
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
      map['data'] = _data!.toJson();
    }
    map['error'] = _error;
    return map;
  }
}

class Data {
  Data({
    String? token,
    int? isAdmin,
    String? authData,
  }) {
    _token = token;
    _isAdmin = isAdmin;
    _authData = authData;
  }

  Data.fromJson(Map<String, dynamic> json) {
    _token = json['token'] as String?;
    _isAdmin = json['is_admin'] as int?;
    _authData = json['auth_data'] as String?;
  }
  String? _token;
  int? _isAdmin;
  String? _authData;
  Data copyWith({
    String? token,
    int? isAdmin,
    String? authData,
  }) =>
      Data(
        token: token ?? _token,
        isAdmin: isAdmin ?? _isAdmin,
        authData: authData ?? _authData,
      );
  String? get token => _token;
  num? get isAdmin => _isAdmin;
  String? get authData => _authData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['is_admin'] = _isAdmin;
    map['auth_data'] = _authData;
    return map;
  }
}
