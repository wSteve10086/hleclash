class LoginState {
  factory LoginState() => _sharedInstance();
  static final LoginState _instance = LoginState._();

  LoginState._() {}

  static LoginState _sharedInstance() {
    return _instance;
  }

  bool value = false;

  /// 0 加载中
  VipState vip = VipState.loading;
  Function loadVip = () {};
}

enum VipState { loading, normal, abnormal, error }
