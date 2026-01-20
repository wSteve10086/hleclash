import 'package:flutter_riverpod/legacy.dart';
import '../cloud_utils/cloud_login_state.dart';
class VipModel {

  final VipState vipState;
  final String planName;
  final String expiredAt;
  final String transferUsed;
  final String totalTransfer;
  final double progress;
  final String email;



  const VipModel({
    this.vipState = VipState.loading,
    this.planName = '',
    this.expiredAt = '',
    this.transferUsed = '',
    this.totalTransfer = '',
    this.progress = 0,
    this.email = '',

  });

  VipModel copyWith({
    VipState? vipState,
    String? planName,
    String? expiredAt,
    String? transferUsed,
    String? totalTransfer,
    double? progress,
    String? email,

  }) {
    return VipModel(
      vipState: vipState ?? this.vipState,
      planName: planName ?? this.planName,
      expiredAt: expiredAt ?? this.expiredAt,
      transferUsed: transferUsed ?? this.transferUsed,
      totalTransfer: totalTransfer ?? this.totalTransfer,
      progress: progress ?? this.progress,
      email: email ?? this.email,
    );
  }
}

/// ✅ 全局唯一 VIP 状态
final vipProvider =
StateProvider<VipModel>((ref) => const VipModel());
