import 'cloud_version_model.dart';

class CloudVersionStorage {
  CloudVersionStorage._privateConstructor();

  static final CloudVersionStorage instance = CloudVersionStorage._privateConstructor();

  CloudVersionModel? _model;

  CloudVersionModel? get model => _model;

  set model(CloudVersionModel? value) {
    _model = value;
  }

  /// 清除缓存
  void clear() {
    _model = null;
  }
}
