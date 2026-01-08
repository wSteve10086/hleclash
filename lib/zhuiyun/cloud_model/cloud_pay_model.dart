class CloudPayModel {
  CloudPayModel({
    num? type,
    dynamic data,
  }) {
    _type = type;
    _data = data;
  }

  CloudPayModel.fromJson(dynamic json) {
    _type = json['type'] as num?;
    _data = json['data'];
  }
  num? _type;
  dynamic _data;
  CloudPayModel copyWith({
    num? type,
    dynamic data,
  }) =>
      CloudPayModel(
        type: type ?? _type,
        data: data ?? _data,
      );
  num? get type => _type;
  dynamic get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['data'] = _data;
    return map;
  }
}
