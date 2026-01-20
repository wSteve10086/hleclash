//
// enum VipState { loading, normal, abnormal, error }
// class LoginState {
//   bool value = false;
//   final VipState _vip = VipState.loading;
//   VipState get vip => _vip;
//   factory LoginState() => _instance;
//
//   LoginState._();
//
//   static final LoginState _instance = LoginState._();
//
//   bool _loaded = false;
//   Future<void> Function()? _loadVip;
//
//   void setLoadVip(Future<void> Function() fn) {
//     _loadVip = fn;
//   }
//
//   Future<void> loadVipIfNeeded() async {
//     if (_loaded) return;
//     _loaded = true;
//     await _loadVip?.call();
//   }
//
//   Future<void> refreshVip() async {
//     _loaded = false;
//     await _loadVip?.call(); // ✅ 不会报错
//   }
//
//
// }

enum VipState { loading, normal, abnormal, error }

class LoginState {
  bool value = false;
  /// ---------------------------
  /// 单例
  /// ---------------------------
  static final LoginState _instance = LoginState._();
  factory LoginState() => _instance;
  LoginState._();

  /// ---------------------------
  /// VIP 状态（❗不能 final）
  /// ---------------------------
  VipState _vip = VipState.loading;
  VipState get vip => _vip;

  /// ---------------------------
  /// 是否已加载
  /// ---------------------------
  bool _loaded = false;

  /// ---------------------------
  /// 外部注入的加载方法
  /// ---------------------------
  Future<void> Function()? _loadVip;

  void setLoadVip(Future<void> Function() fn) {
    _loadVip = fn;
  }

  /// ---------------------------
  /// 唯一修改 VIP 的方式
  /// ---------------------------
  void updateVip(VipState state) {
    _vip = state;
  }

  /// ---------------------------
  /// 首次加载（只执行一次）
  /// ---------------------------
  Future<void> loadVipIfNeeded() async {
    if (_loaded) return;
    _loaded = true;

    updateVip(VipState.loading);

    try {
      await _loadVip?.call();
    } catch (_) {
      updateVip(VipState.error);
    }
  }

  /// ---------------------------
  /// 强制刷新（支付成功 / 手动）
  /// ---------------------------
  Future<void> refreshVip() async {
    _loaded = false;
    await loadVipIfNeeded(); // ✅ 关键
  }

  /// ---------------------------
  /// 退出登录
  /// ---------------------------
  void reset() {
    _loaded = false;
    _vip = VipState.loading;
  }
}
