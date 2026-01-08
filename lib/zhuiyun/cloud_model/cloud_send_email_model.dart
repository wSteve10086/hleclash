

class CloudSendEmailModel {
  CloudSendEmailModel({
    bool? data,
  }) {
    _data = data;
  }

  CloudSendEmailModel.fromJson(Map<String,dynamic> json) {
    _data = json['data'] as bool?;
  }
  bool? _data;
  CloudSendEmailModel copyWith({
    bool? data,
  }) =>
      CloudSendEmailModel(
        data: data ?? _data,
      );
  bool? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = _data;
    return map;
  }
}
