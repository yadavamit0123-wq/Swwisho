import 'package:demandium/feature/provider/model/provider_model.dart';
import 'package:demandium/feature/service/model/service_model.dart';

class CartModel {
  String? _id;
  String? _serviceId;
  String? _categoryId;
  String? _subCategoryId;
  String? _variantKey;
  num? _serviceCost;
  int? _quantity;
  num? _discountAmount;
  num? _commission;
  num? _gstOnCommission;
  num? _travelingCharge;
  num? _campaignDiscountAmount;
  num? _couponDiscountAmount;
  num? _referralDiscountAmount;
  String? _couponCode;
  int? _couponRemainingUses;
  num? _taxAmount;
  num? _totalCost;
  Service? _service;
  ProviderData? _provider;

  CartModel(
      String id,
      String serviceId,
      String categoryId,
      String subCategoryId,
      String variantKey,
      num serviceCost,
      int quantity,
      num discountAmount,
      num commission,
      num gstOnCommission,
      num travelingCharge,
      num campaignDiscountAmount,
      num couponDiscountAmount,
      num referralDiscountAmount,
      String? couponCode,
      int? couponRemainingUses,
      num taxAmount,
      num totalCost,
      Service service,
      {
        ProviderData? provider
      })
  {
  _id = id;
  _serviceId = serviceId;
  _categoryId = categoryId;
  _subCategoryId = subCategoryId;
  _variantKey = variantKey;
  _serviceCost = serviceCost;
  _quantity = quantity;
  _discountAmount = discountAmount;
  _commission = commission;
  _gstOnCommission = gstOnCommission;
  _travelingCharge = travelingCharge;
  _campaignDiscountAmount = campaignDiscountAmount;
  _couponDiscountAmount = couponDiscountAmount;
  _referralDiscountAmount = referralDiscountAmount;
  _couponCode = couponCode;
  _couponRemainingUses = couponRemainingUses;
  _taxAmount = taxAmount;
  _totalCost = totalCost;
  _service = service;
  _provider = provider;
  }

  String get id => _id!;
  Service? get service => _service;
  ProviderData? get provider => _provider;

  String get serviceId => _serviceId ?? '';
  String get categoryId => _categoryId ?? '';
  String get variantKey => _variantKey ?? '';
  String get subCategoryId => _subCategoryId ?? '';

  num get price => _serviceCost ?? 0;
  num get discountedPrice => _discountAmount ?? 0;
  num get commission => _commission ?? 0;
  num get gstOnCommission => _gstOnCommission ?? 0;
  num get travelingCharge => _travelingCharge ?? 0;
  num get campaignDiscountPrice => _campaignDiscountAmount ?? 0;
  num get couponDiscountPrice => _couponDiscountAmount ?? 0;
  num get referralDiscountAmount => _referralDiscountAmount ?? 0;
  String? get couponCode => _couponCode;
  int? get couponRemainingUses => _couponRemainingUses;
  num get taxAmount => _taxAmount ?? 0;
  num get totalCost => _totalCost ?? 0;
  num get serviceCost => _serviceCost ?? 0;
  // ignore: unnecessary_getters_setters
  int get quantity => _quantity ?? 0;

  // ignore: unnecessary_getters_setters
  set quantity(int qty) => _quantity = qty;

  CartModel copyWith({String? id, int? quantity}) {
    if(id != null) {
      _id = id;
    }

    if(quantity != null) {
      _quantity = quantity;
    }
    return this;
}

  CartModel.fromJson(Map<String, dynamic> json) {
    _id = json['id']?.toString();
    _serviceId = json['service_id']?.toString();
    _categoryId = json['category_id']?.toString();
    _subCategoryId = json['sub_category_id']?.toString();
    _variantKey = json['variant_key']?.toString();
    _serviceCost = num.tryParse(json['service_cost']?.toString() ?? '');
    _quantity = int.tryParse(json['quantity']?.toString() ?? '');
    _discountAmount = num.tryParse(json['discount_amount']?.toString() ?? '');
    _commission = num.tryParse(json['comission']?.toString() ?? '');
    _gstOnCommission = num.tryParse(json['gst_on_comission']?.toString() ?? '');
    _travelingCharge = num.tryParse(json['traveling_charge']?.toString() ?? '');
    _campaignDiscountAmount = num.tryParse(json['campaign_discount']?.toString() ?? '');
    _couponDiscountAmount = num.tryParse(json['coupon_discount']?.toString() ?? '');
    _referralDiscountAmount = double.tryParse(json['referral_discount']?.toString() ?? '');
    _couponCode = json['coupon_code']?.toString();
    _couponRemainingUses = int.tryParse(json['remaining_uses']?.toString() ?? '');
    _taxAmount = num.tryParse(json['tax_amount']?.toString() ?? '');
    _totalCost = num.tryParse(json['total_cost']?.toString() ?? '');
    _service = json['service'] is Map ? Service.fromJson(Map<String, dynamic>.from(json['service'])) : null;
    _provider = json['provider'] is Map ? ProviderData.fromJson(Map<String, dynamic>.from(json['provider'])) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['service_id'] = _serviceId;
    data['category_id'] = _categoryId;
    data['sub_category_id'] = _subCategoryId;
    data['variant_key'] = _variantKey;
    data['service_cost'] = _serviceCost;
    data['quantity'] = _quantity;
    data['discount_amount'] = _discountAmount;
    data['comission'] = _commission;
    data['gst_on_comission'] = _gstOnCommission;
    data['traveling_charge'] = _travelingCharge;
    data['campaign_discount'] = _campaignDiscountAmount;
    data['coupon_discount'] = _couponDiscountAmount;
    data['referral_discount'] = _referralDiscountAmount;
    data['coupon_code'] = _couponCode;
    data['tax_amount'] = _taxAmount;
    data['total_cost'] = _totalCost;
    data['service'] = _service;
    data['service'] = service?.toJson();
    data['provider'] = provider?.toJson();
    return data;
  }
}
