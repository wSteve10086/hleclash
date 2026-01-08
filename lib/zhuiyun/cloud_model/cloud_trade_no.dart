class CloudTradeNo {
  CloudTradeNo({
    String? status,
    String? message,
    String? data,
    dynamic error,
  }) {
    _status = status;
    _message = message;
    _data = data;
    _error = error;
  }

  CloudTradeNo.fromJson(dynamic json) {
    _status = json['status'] as String?;
    _message = json['message'] as String?;
    _data = json['data'] as String?;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  String? _data;
  dynamic _error;
  CloudTradeNo copyWith({
    String? status,
    String? message,
    String? data,
    dynamic error,
  }) =>
      CloudTradeNo(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
        error: error ?? _error,
      );
  String? get status => _status;
  String? get message => _message;
  String? get data => _data;
  dynamic get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    map['data'] = _data;
    map['error'] = _error;
    return map;
  }
}
