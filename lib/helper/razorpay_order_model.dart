class RazorpayOrderModel {
  final String key;
  final String orderId;
  final int amount;
  final String currency;
  final String? name;
  final String? description;
  final String? image;
  final String? callbackUrl;
  final Map<String, String> prefill;

  RazorpayOrderModel({
    required this.key,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.name,
    this.description,
    this.image,
    this.callbackUrl,
    this.prefill = const {},
  });

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    final prefillData = json['prefill'];
    Map<String, String> prefill = {};
    if (prefillData is Map) {
      prefillData.forEach((key, value) {
        if (value != null) {
          prefill[key.toString()] = value.toString();
        }
      });
    }

    return RazorpayOrderModel(
      key: _readString(json, ['key', 'gateway_key', 'api_key', 'razor_key', 'public_key']) ?? '',
      orderId: _readString(json, ['order_id', 'razorpay_order_id', 'orderId']) ?? '',
      amount: _readInt(json, ['amount', 'total_amount', 'payable_amount']) ?? 0,
      currency: _readString(json, ['currency', 'currency_code']) ?? 'INR',
      name: _readString(json, ['name', 'business_name', 'merchant_name']),
      description: _readString(json, ['description', 'payment_description']),
      image: _readString(json, ['image', 'logo', 'business_logo']),
      callbackUrl: _readString(json, ['callback_url', 'callback', 'redirect_url', 'success_url']),
      prefill: prefill,
    );
  }

  bool get isValid => key.isNotEmpty && orderId.isNotEmpty && amount > 0;

  Map<String, dynamic> toCheckoutOptions() {
    return {
      'key': key,
      'amount': amount,
      'currency': currency,
      'order_id': orderId,
      'name': name ?? 'Swwisho',
      'description': description ?? 'Payment',
      if (image != null && image!.isNotEmpty) 'image': image,
      'prefill': prefill,
      'theme': {'color': '#3399cc'},
      'config': {
        'display': {
          'blocks': {
            'upi': {
              'name': 'Pay via UPI',
              'instruments': [
                {'method': 'upi', 'flows': ['intent']},
              ],
            },
          },
          'sequence': ['block.upi'],
          'preferences': {'show_default_blocks': false},
        },
      },
    };
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}
