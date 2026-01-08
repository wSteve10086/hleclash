

class CloudCancelOrderModel {
  CloudCancelOrderModel({
      String? status, 
      String? message, 
      bool? data, 
      dynamic error,}){
    _status = status;
    _message = message;
    _data = data;
    _error = error;
}

  CloudCancelOrderModel.fromJson(dynamic json) {
    _status = json['status']as String?;
    _message = json['message']as String?;
    _data = json['data']as bool?;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  bool? _data;
  dynamic _error;
CloudCancelOrderModel copyWith({  String? status,
  String? message,
  bool? data,
  dynamic error,
}) => CloudCancelOrderModel(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
  error: error ?? _error,
);
  String? get status => _status;
  String? get message => _message;
  bool? get data => _data;
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
