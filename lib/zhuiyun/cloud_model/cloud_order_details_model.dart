class CloudOrderDetailsModel {
  CloudOrderDetailsModel({
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

  CloudOrderDetailsModel.fromJson(dynamic json) {
    _status = json['status'] as String?;
    _message = json['message'] as String?;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _error = json['error'];
  }
  String? _status;
  String? _message;
  Data? _data;
  dynamic _error;
  CloudOrderDetailsModel copyWith({
    String? status,
    String? message,
    Data? data,
    dynamic error,
  }) =>
      CloudOrderDetailsModel(
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

/// id : 166320
/// invite_user_id : null
/// user_id : 356330
/// plan_id : 40
/// coupon_id : null
/// payment_id : 5
/// type : 3
/// period : "quarter_price"
/// trade_no : "2024041717041705065327778"
/// callback_no : null
/// total_amount : 2068
/// handling_amount : null
/// discount_amount : null
/// surplus_amount : 32
/// refund_amount : null
/// balance_amount : null
/// surplus_order_ids : [158992]
/// status : 2
/// commission_status : 0
/// commission_balance : 0
/// actual_commission_balance : null
/// paid_at : null
/// created_at : 1713345437
/// updated_at : 1713352682
/// plan : {"id":40,"group_id":1,"transfer_enable":270,"name":"套餐 A-季付","speed_limit":null,"show":1,"sort":21,"renew":1,"content":"①  270G流量 90 天有效期&#x2714;<br>\n ② 高速VIP1节点通用&#x2714;<br>\n ③ 1000Mbps峰值速率&#x2714;<br>\n ④ 线上客服快速响应&#x2714;<br>\n ⑤ 解锁部分流媒体(Netflix、Disney)&#x2714;<br>\n ⑥ 限制五台设备&#x2714;<br>","month_price":null,"quarter_price":2100,"half_year_price":null,"year_price":null,"two_year_price":null,"three_year_price":null,"onetime_price":null,"reset_price":null,"reset_traffic_method":2,"capacity_limit":null,"created_at":1691550917,"updated_at":1738461583}
/// try_out_plan_id : 16
/// surplus_orders : [{"id":158992,"invite_user_id":null,"user_id":356330,"plan_id":35,"coupon_id":null,"payment_id":5,"type":3,"period":"month_price","trade_no":"2024031822034402373217590","callback_no":"2024031822534850538","total_amount":800,"handling_amount":null,"discount_amount":null,"surplus_amount":null,"refund_amount":null,"balance_amount":null,"surplus_order_ids":null,"status":3,"commission_status":0,"commission_balance":0,"actual_commission_balance":null,"paid_at":1710773657,"created_at":1710773624,"updated_at":1710773657}]

class Data {
  Data({
    num? id,
    dynamic inviteUserId,
    num? userId,
    num? planId,
    dynamic couponId,
    num? paymentId,
    num? type,
    String? period,
    String? tradeNo,
    dynamic callbackNo,
    num? totalAmount,
    num? handlingAmount,
    num? discountAmount,
    num? surplusAmount,
    num? refundAmount,
    num? balanceAmount,
    List<num>? surplusOrderIds,
    num? status,
    num? commissionStatus,
    num? commissionBalance,
    dynamic actualCommissionBalance,
    dynamic paidAt,
    num? createdAt,
    num? updatedAt,
    Plan? plan,
    num? tryOutPlanId,
    List<SurplusOrders>? surplusOrders,
  }) {
    _id = id;
    _inviteUserId = inviteUserId;
    _userId = userId;
    _planId = planId;
    _couponId = couponId;
    _paymentId = paymentId;
    _type = type;
    _period = period;
    _tradeNo = tradeNo;
    _callbackNo = callbackNo;
    _totalAmount = totalAmount;
    _handlingAmount = handlingAmount;
    _discountAmount = discountAmount;
    _surplusAmount = surplusAmount;
    _refundAmount = refundAmount;
    _balanceAmount = balanceAmount;
    _surplusOrderIds = surplusOrderIds;
    _status = status;
    _commissionStatus = commissionStatus;
    _commissionBalance = commissionBalance;
    _actualCommissionBalance = actualCommissionBalance;
    _paidAt = paidAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _plan = plan;
    _tryOutPlanId = tryOutPlanId;
    _surplusOrders = surplusOrders;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'] as num?;
    _inviteUserId = json['invite_user_id'];
    _userId = json['user_id'] as num?;
    _planId = json['plan_id'] as num?;
    _couponId = json['coupon_id'];
    _paymentId = json['payment_id'] as num?;
    _type = json['type'] as num?;
    _period = json['period'] as String?;
    _tradeNo = json['trade_no'] as String?;
    _callbackNo = json['callback_no'];
    _totalAmount = json['total_amount'] as num?;
    _handlingAmount = json['handling_amount'] as num?;
    _discountAmount = json['discount_amount'] as num?;
    _surplusAmount = json['surplus_amount'] as num?;
    _refundAmount = json['refund_amount'] as num?;
    _balanceAmount = json['balance_amount'] as num?;
    _surplusOrderIds = json['surplus_order_ids'] != null
        ? (json['surplus_order_ids'] as List<dynamic>).cast<num>()
        : [];
    _status = json['status'] as num?;
    _commissionStatus = json['commission_status'] as num?;
    _commissionBalance = json['commission_balance'] as num?;
    _actualCommissionBalance = json['actual_commission_balance'];
    _paidAt = json['paid_at'];
    _createdAt = json['created_at'] as num?;
    _updatedAt = json['updated_at'] as num?;
    _plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
    _tryOutPlanId = json['try_out_plan_id'] as num?;
    if (json['surplus_orders'] != null) {
      _surplusOrders = [];
      json['surplus_orders'].forEach((v) {
        _surplusOrders?.add(SurplusOrders.fromJson(v));
      });
    }
  }
  num? _id;
  dynamic _inviteUserId;
  num? _userId;
  num? _planId;
  dynamic _couponId;
  num? _paymentId;
  num? _type;
  String? _period;
  String? _tradeNo;
  dynamic _callbackNo;
  num? _totalAmount;
  num? _handlingAmount;
  num? _discountAmount;
  num? _surplusAmount;
  num? _refundAmount;
  num? _balanceAmount;
  List<num>? _surplusOrderIds;
  num? _status;
  num? _commissionStatus;
  num? _commissionBalance;
  dynamic _actualCommissionBalance;
  dynamic _paidAt;
  num? _createdAt;
  num? _updatedAt;
  Plan? _plan;
  num? _tryOutPlanId;
  List<SurplusOrders>? _surplusOrders;
  Data copyWith({
    num? id,
    dynamic inviteUserId,
    num? userId,
    num? planId,
    dynamic couponId,
    num? paymentId,
    num? type,
    String? period,
    String? tradeNo,
    dynamic callbackNo,
    num? totalAmount,
    num? handlingAmount,
    num? discountAmount,
    num? surplusAmount,
    num? refundAmount,
    num? balanceAmount,
    List<num>? surplusOrderIds,
    num? status,
    num? commissionStatus,
    num? commissionBalance,
    dynamic actualCommissionBalance,
    dynamic paidAt,
    num? createdAt,
    num? updatedAt,
    Plan? plan,
    num? tryOutPlanId,
    List<SurplusOrders>? surplusOrders,
  }) =>
      Data(
        id: id ?? _id,
        inviteUserId: inviteUserId ?? _inviteUserId,
        userId: userId ?? _userId,
        planId: planId ?? _planId,
        couponId: couponId ?? _couponId,
        paymentId: paymentId ?? _paymentId,
        type: type ?? _type,
        period: period ?? _period,
        tradeNo: tradeNo ?? _tradeNo,
        callbackNo: callbackNo ?? _callbackNo,
        totalAmount: totalAmount ?? _totalAmount,
        handlingAmount: handlingAmount ?? _handlingAmount,
        discountAmount: discountAmount ?? _discountAmount,
        surplusAmount: surplusAmount ?? _surplusAmount,
        refundAmount: refundAmount ?? _refundAmount,
        balanceAmount: balanceAmount ?? _balanceAmount,
        surplusOrderIds: surplusOrderIds ?? _surplusOrderIds,
        status: status ?? _status,
        commissionStatus: commissionStatus ?? _commissionStatus,
        commissionBalance: commissionBalance ?? _commissionBalance,
        actualCommissionBalance:
            actualCommissionBalance ?? _actualCommissionBalance,
        paidAt: paidAt ?? _paidAt,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        plan: plan ?? _plan,
        tryOutPlanId: tryOutPlanId ?? _tryOutPlanId,
        surplusOrders: surplusOrders ?? _surplusOrders,
      );
  num? get id => _id;
  dynamic get inviteUserId => _inviteUserId;
  num? get userId => _userId;
  num? get planId => _planId;
  dynamic get couponId => _couponId;
  num? get paymentId => _paymentId;
  num? get type => _type;
  String? get period => _period;
  String? get tradeNo => _tradeNo;
  dynamic get callbackNo => _callbackNo;
  num? get totalAmount => _totalAmount;
  num? get handlingAmount => _handlingAmount;
  num? get discountAmount => _discountAmount;
  num? get surplusAmount => _surplusAmount;
  num? get refundAmount => _refundAmount;
  num? get balanceAmount => _balanceAmount;
  List<num>? get surplusOrderIds => _surplusOrderIds;
  num? get status => _status;
  num? get commissionStatus => _commissionStatus;
  num? get commissionBalance => _commissionBalance;
  dynamic get actualCommissionBalance => _actualCommissionBalance;
  dynamic get paidAt => _paidAt;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;
  Plan? get plan => _plan;
  num? get tryOutPlanId => _tryOutPlanId;
  List<SurplusOrders>? get surplusOrders => _surplusOrders;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['invite_user_id'] = _inviteUserId;
    map['user_id'] = _userId;
    map['plan_id'] = _planId;
    map['coupon_id'] = _couponId;
    map['payment_id'] = _paymentId;
    map['type'] = _type;
    map['period'] = _period;
    map['trade_no'] = _tradeNo;
    map['callback_no'] = _callbackNo;
    map['total_amount'] = _totalAmount;
    map['handling_amount'] = _handlingAmount;
    map['discount_amount'] = _discountAmount;
    map['surplus_amount'] = _surplusAmount;
    map['refund_amount'] = _refundAmount;
    map['balance_amount'] = _balanceAmount;
    map['surplus_order_ids'] = _surplusOrderIds;
    map['status'] = _status;
    map['commission_status'] = _commissionStatus;
    map['commission_balance'] = _commissionBalance;
    map['actual_commission_balance'] = _actualCommissionBalance;
    map['paid_at'] = _paidAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_plan != null) {
      map['plan'] = _plan?.toJson();
    }
    map['try_out_plan_id'] = _tryOutPlanId;
    if (_surplusOrders != null) {
      map['surplus_orders'] = _surplusOrders?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 158992
/// invite_user_id : null
/// user_id : 356330
/// plan_id : 35
/// coupon_id : null
/// payment_id : 5
/// type : 3
/// period : "month_price"
/// trade_no : "2024031822034402373217590"
/// callback_no : "2024031822534850538"
/// total_amount : 800
/// handling_amount : null
/// discount_amount : null
/// surplus_amount : null
/// refund_amount : null
/// balance_amount : null
/// surplus_order_ids : null
/// status : 3
/// commission_status : 0
/// commission_balance : 0
/// actual_commission_balance : null
/// paid_at : 1710773657
/// created_at : 1710773624
/// updated_at : 1710773657

class SurplusOrders {
  SurplusOrders({
    num? id,
    dynamic inviteUserId,
    num? userId,
    num? planId,
    dynamic couponId,
    num? paymentId,
    num? type,
    String? period,
    String? tradeNo,
    String? callbackNo,
    num? totalAmount,
    num? handlingAmount,
    num? discountAmount,
    num? surplusAmount,
    num? refundAmount,
    num? balanceAmount,
    dynamic surplusOrderIds,
    num? status,
    num? commissionStatus,
    num? commissionBalance,
    dynamic actualCommissionBalance,
    num? paidAt,
    num? createdAt,
    num? updatedAt,
  }) {
    _id = id;
    _inviteUserId = inviteUserId;
    _userId = userId;
    _planId = planId;
    _couponId = couponId;
    _paymentId = paymentId;
    _type = type;
    _period = period;
    _tradeNo = tradeNo;
    _callbackNo = callbackNo;
    _totalAmount = totalAmount;
    _handlingAmount = handlingAmount;
    _discountAmount = discountAmount;
    _surplusAmount = surplusAmount;
    _refundAmount = refundAmount;
    _balanceAmount = balanceAmount;
    _surplusOrderIds = surplusOrderIds;
    _status = status;
    _commissionStatus = commissionStatus;
    _commissionBalance = commissionBalance;
    _actualCommissionBalance = actualCommissionBalance;
    _paidAt = paidAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  SurplusOrders.fromJson(dynamic json) {
    _id = json['id'] as num?;
    _inviteUserId = json['invite_user_id'];
    _userId = json['user_id'] as num?;
    _planId = json['plan_id'] as num?;
    _couponId = json['coupon_id'];
    _paymentId = json['payment_id'] as num?;
    _type = json['type'] as num?;
    _period = json['period'] as String?;
    _tradeNo = json['trade_no'] as String?;
    _callbackNo = json['callback_no'] as String?;
    _totalAmount = json['total_amount'] as num?;
    _handlingAmount = json['handling_amount'] as num?;
    _discountAmount = json['discount_amount'] as num?;
    _surplusAmount = json['surplus_amount'] as num?;
    _refundAmount = json['refund_amount'] as num?;
    _balanceAmount = json['balance_amount'] as num?;
    _surplusOrderIds = json['surplus_order_ids'];
    _status = json['status'] as num?;
    _commissionStatus = json['commission_status'] as num?;
    _commissionBalance = json['commission_balance'] as num?;
    _actualCommissionBalance = json['actual_commission_balance'];
    _paidAt = json['paid_at'] as num?;
    _createdAt = json['created_at'] as num?;
    _updatedAt = json['updated_at'] as num?;
  }
  num? _id;
  dynamic _inviteUserId;
  num? _userId;
  num? _planId;
  dynamic _couponId;
  num? _paymentId;
  num? _type;
  String? _period;
  String? _tradeNo;
  String? _callbackNo;
  num? _totalAmount;
  num? _handlingAmount;
  num? _discountAmount;
  num? _surplusAmount;
  num? _refundAmount;
  num? _balanceAmount;
  dynamic _surplusOrderIds;
  num? _status;
  num? _commissionStatus;
  num? _commissionBalance;
  dynamic _actualCommissionBalance;
  num? _paidAt;
  num? _createdAt;
  num? _updatedAt;
  SurplusOrders copyWith({
    num? id,
    dynamic inviteUserId,
    num? userId,
    num? planId,
    dynamic couponId,
    num? paymentId,
    num? type,
    String? period,
    String? tradeNo,
    String? callbackNo,
    num? totalAmount,
    num? handlingAmount,
    num? discountAmount,
    num? surplusAmount,
    num? refundAmount,
    num? balanceAmount,
    dynamic surplusOrderIds,
    num? status,
    num? commissionStatus,
    num? commissionBalance,
    dynamic actualCommissionBalance,
    num? paidAt,
    num? createdAt,
    num? updatedAt,
  }) =>
      SurplusOrders(
        id: id ?? _id,
        inviteUserId: inviteUserId ?? _inviteUserId,
        userId: userId ?? _userId,
        planId: planId ?? _planId,
        couponId: couponId ?? _couponId,
        paymentId: paymentId ?? _paymentId,
        type: type ?? _type,
        period: period ?? _period,
        tradeNo: tradeNo ?? _tradeNo,
        callbackNo: callbackNo ?? _callbackNo,
        totalAmount: totalAmount ?? _totalAmount,
        handlingAmount: handlingAmount ?? _handlingAmount,
        discountAmount: discountAmount ?? _discountAmount,
        surplusAmount: surplusAmount ?? _surplusAmount,
        refundAmount: refundAmount ?? _refundAmount,
        balanceAmount: balanceAmount ?? _balanceAmount,
        surplusOrderIds: surplusOrderIds ?? _surplusOrderIds,
        status: status ?? _status,
        commissionStatus: commissionStatus ?? _commissionStatus,
        commissionBalance: commissionBalance ?? _commissionBalance,
        actualCommissionBalance:
            actualCommissionBalance ?? _actualCommissionBalance,
        paidAt: paidAt ?? _paidAt,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  dynamic get inviteUserId => _inviteUserId;
  num? get userId => _userId;
  num? get planId => _planId;
  dynamic get couponId => _couponId;
  num? get paymentId => _paymentId;
  num? get type => _type;
  String? get period => _period;
  String? get tradeNo => _tradeNo;
  String? get callbackNo => _callbackNo;
  num? get totalAmount => _totalAmount;
  num? get handlingAmount => _handlingAmount;
  num? get discountAmount => _discountAmount;
  num? get surplusAmount => _surplusAmount;
  num? get refundAmount => _refundAmount;
  num? get balanceAmount => _balanceAmount;
  dynamic get surplusOrderIds => _surplusOrderIds;
  num? get status => _status;
  num? get commissionStatus => _commissionStatus;
  num? get commissionBalance => _commissionBalance;
  dynamic get actualCommissionBalance => _actualCommissionBalance;
  num? get paidAt => _paidAt;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['invite_user_id'] = _inviteUserId;
    map['user_id'] = _userId;
    map['plan_id'] = _planId;
    map['coupon_id'] = _couponId;
    map['payment_id'] = _paymentId;
    map['type'] = _type;
    map['period'] = _period;
    map['trade_no'] = _tradeNo;
    map['callback_no'] = _callbackNo;
    map['total_amount'] = _totalAmount;
    map['handling_amount'] = _handlingAmount;
    map['discount_amount'] = _discountAmount;
    map['surplus_amount'] = _surplusAmount;
    map['refund_amount'] = _refundAmount;
    map['balance_amount'] = _balanceAmount;
    map['surplus_order_ids'] = _surplusOrderIds;
    map['status'] = _status;
    map['commission_status'] = _commissionStatus;
    map['commission_balance'] = _commissionBalance;
    map['actual_commission_balance'] = _actualCommissionBalance;
    map['paid_at'] = _paidAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}

/// id : 40
/// group_id : 1
/// transfer_enable : 270
/// name : "套餐 A-季付"
/// speed_limit : null
/// show : 1
/// sort : 21
/// renew : 1
/// content : "①  270G流量 90 天有效期&#x2714;<br>\n ② 高速VIP1节点通用&#x2714;<br>\n ③ 1000Mbps峰值速率&#x2714;<br>\n ④ 线上客服快速响应&#x2714;<br>\n ⑤ 解锁部分流媒体(Netflix、Disney)&#x2714;<br>\n ⑥ 限制五台设备&#x2714;<br>"
/// month_price : null
/// quarter_price : 2100
/// half_year_price : null
/// year_price : null
/// two_year_price : null
/// three_year_price : null
/// onetime_price : null
/// reset_price : null
/// reset_traffic_method : 2
/// capacity_limit : null
/// created_at : 1691550917
/// updated_at : 1738461583

class Plan {
  Plan({
    num? id,
    num? groupId,
    num? transferEnable,
    String? name,
    dynamic speedLimit,
    num? show,
    num? sort,
    num? renew,
    String? content,
    dynamic monthPrice,
    num? quarterPrice,
    dynamic halfYearPrice,
    dynamic yearPrice,
    dynamic twoYearPrice,
    dynamic threeYearPrice,
    dynamic onetimePrice,
    dynamic resetPrice,
    num? resetTrafficMethod,
    dynamic capacityLimit,
    num? createdAt,
    num? updatedAt,
  }) {
    _id = id;
    _groupId = groupId;
    _transferEnable = transferEnable;
    _name = name;
    _speedLimit = speedLimit;
    _show = show;
    _sort = sort;
    _renew = renew;
    _content = content;
    _monthPrice = monthPrice;
    _quarterPrice = quarterPrice;
    _halfYearPrice = halfYearPrice;
    _yearPrice = yearPrice;
    _twoYearPrice = twoYearPrice;
    _threeYearPrice = threeYearPrice;
    _onetimePrice = onetimePrice;
    _resetPrice = resetPrice;
    _resetTrafficMethod = resetTrafficMethod;
    _capacityLimit = capacityLimit;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Plan.fromJson(dynamic json) {
    _id = json['id'] as num?;
    _groupId = json['group_id'] as num?;
    _transferEnable = json['transfer_enable'] as num?;
    _name = json['name'] as String?;
    _speedLimit = json['speed_limit'];
    _show = json['show'] as num?;
    _sort = json['sort'] as num?;
    _renew = json['renew'] as num?;
    _content = json['content'] as String?;
    _monthPrice = json['month_price'];
    _quarterPrice = json['quarter_price'] as num?;
    _halfYearPrice = json['half_year_price'];
    _yearPrice = json['year_price'];
    _twoYearPrice = json['two_year_price'];
    _threeYearPrice = json['three_year_price'];
    _onetimePrice = json['onetime_price'];
    _resetPrice = json['reset_price'];
    _resetTrafficMethod = json['reset_traffic_method'] as num?;
    _capacityLimit = json['capacity_limit'];
    _createdAt = json['created_at'] as num?;
    _updatedAt = json['updated_at'] as num?;
  }
  num? _id;
  num? _groupId;
  num? _transferEnable;
  String? _name;
  dynamic _speedLimit;
  num? _show;
  num? _sort;
  num? _renew;
  String? _content;
  dynamic _monthPrice;
  num? _quarterPrice;
  dynamic _halfYearPrice;
  dynamic _yearPrice;
  dynamic _twoYearPrice;
  dynamic _threeYearPrice;
  dynamic _onetimePrice;
  dynamic _resetPrice;
  num? _resetTrafficMethod;
  dynamic _capacityLimit;
  num? _createdAt;
  num? _updatedAt;
  Plan copyWith({
    num? id,
    num? groupId,
    num? transferEnable,
    String? name,
    dynamic speedLimit,
    num? show,
    num? sort,
    num? renew,
    String? content,
    dynamic monthPrice,
    num? quarterPrice,
    dynamic halfYearPrice,
    dynamic yearPrice,
    dynamic twoYearPrice,
    dynamic threeYearPrice,
    dynamic onetimePrice,
    dynamic resetPrice,
    num? resetTrafficMethod,
    dynamic capacityLimit,
    num? createdAt,
    num? updatedAt,
  }) =>
      Plan(
        id: id ?? _id,
        groupId: groupId ?? _groupId,
        transferEnable: transferEnable ?? _transferEnable,
        name: name ?? _name,
        speedLimit: speedLimit ?? _speedLimit,
        show: show ?? _show,
        sort: sort ?? _sort,
        renew: renew ?? _renew,
        content: content ?? _content,
        monthPrice: monthPrice ?? _monthPrice,
        quarterPrice: quarterPrice ?? _quarterPrice,
        halfYearPrice: halfYearPrice ?? _halfYearPrice,
        yearPrice: yearPrice ?? _yearPrice,
        twoYearPrice: twoYearPrice ?? _twoYearPrice,
        threeYearPrice: threeYearPrice ?? _threeYearPrice,
        onetimePrice: onetimePrice ?? _onetimePrice,
        resetPrice: resetPrice ?? _resetPrice,
        resetTrafficMethod: resetTrafficMethod ?? _resetTrafficMethod,
        capacityLimit: capacityLimit ?? _capacityLimit,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  num? get groupId => _groupId;
  num? get transferEnable => _transferEnable;
  String? get name => _name;
  dynamic get speedLimit => _speedLimit;
  num? get show => _show;
  num? get sort => _sort;
  num? get renew => _renew;
  String? get content => _content;
  dynamic get monthPrice => _monthPrice;
  num? get quarterPrice => _quarterPrice;
  dynamic get halfYearPrice => _halfYearPrice;
  dynamic get yearPrice => _yearPrice;
  dynamic get twoYearPrice => _twoYearPrice;
  dynamic get threeYearPrice => _threeYearPrice;
  dynamic get onetimePrice => _onetimePrice;
  dynamic get resetPrice => _resetPrice;
  num? get resetTrafficMethod => _resetTrafficMethod;
  dynamic get capacityLimit => _capacityLimit;
  num? get createdAt => _createdAt;
  num? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['group_id'] = _groupId;
    map['transfer_enable'] = _transferEnable;
    map['name'] = _name;
    map['speed_limit'] = _speedLimit;
    map['show'] = _show;
    map['sort'] = _sort;
    map['renew'] = _renew;
    map['content'] = _content;
    map['month_price'] = _monthPrice;
    map['quarter_price'] = _quarterPrice;
    map['half_year_price'] = _halfYearPrice;
    map['year_price'] = _yearPrice;
    map['two_year_price'] = _twoYearPrice;
    map['three_year_price'] = _threeYearPrice;
    map['onetime_price'] = _onetimePrice;
    map['reset_price'] = _resetPrice;
    map['reset_traffic_method'] = _resetTrafficMethod;
    map['capacity_limit'] = _capacityLimit;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
