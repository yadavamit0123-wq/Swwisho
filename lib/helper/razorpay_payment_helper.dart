import 'dart:async';
import 'dart:convert';

import 'package:demandium/helper/razorpay_order_model.dart';
import 'package:demandium/utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentHelper {
  static Razorpay? _razorpay;
  static Completer<bool>? _paymentCompleter;
  static String _paymentUrl = '';
  static RazorpayOrderModel? _orderData;
  static Future<void> Function(String redirectUrl)? _onRedirect;

  static Future<bool> startPayment({
    required String paymentUrl,
    required Future<void> Function(String redirectUrl) onRedirect,
  }) async {
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) {
      return false;
    }

    try {
      final orderData = await _fetchOrderData(paymentUrl);
      if (orderData == null || !orderData.isValid) {
        return false;
      }

      _paymentUrl = paymentUrl;
      _orderData = orderData;
      _onRedirect = onRedirect;
      _paymentCompleter = Completer<bool>();

      _razorpay?.clear();
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      _razorpay!.open(orderData.toCheckoutOptions());
      return await _paymentCompleter!.future;
    } catch (e) {
      if (kDebugMode) {
        print('RazorpayPaymentHelper.startPayment: $e');
      }
      _dispose();
      return false;
    }
  }

  static Future<RazorpayOrderModel?> _fetchOrderData(String paymentUrl) async {
    final uri = Uri.parse(paymentUrl);
    final sdkUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'sdk': '1',
    });

    final response = await http.get(
      sdkUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      return null;
    }

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      return null;
    }

    if (body is! Map<String, dynamic>) {
      return null;
    }

    final content = body['content'];
    if (content is Map<String, dynamic>) {
      return RazorpayOrderModel.fromJson(content);
    }

    return null;
  }

  static Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final redirectUrl = await _verifyPayment(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        await _onRedirect?.call(redirectUrl);
        _paymentCompleter?.complete(true);
      } else {
        _paymentCompleter?.complete(false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('RazorpayPaymentHelper._handlePaymentSuccess: $e');
      }
      _paymentCompleter?.complete(false);
    } finally {
      _dispose();
    }
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('RazorpayPaymentHelper error: ${response.code} ${response.message}');
    }
    _paymentCompleter?.complete(false);
    _dispose();
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('RazorpayPaymentHelper external wallet: ${response.walletName}');
    }
  }

  static Future<String?> _verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    final params = {
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
      'razorpay_signature': signature,
    };

    final targets = <Uri>[];

    if (_orderData?.callbackUrl != null && _orderData!.callbackUrl!.isNotEmpty) {
      targets.add(_appendParams(Uri.parse(_orderData!.callbackUrl!), params));
    }

    targets.add(_appendParams(Uri.parse(_paymentUrl), params));
    targets.add(Uri.parse('${AppConstants.baseUrl}/payment/razor-pay/callback').replace(queryParameters: params));

    for (final uri in targets) {
      final redirectUrl = await _requestRedirect(uri);
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        return redirectUrl;
      }
    }

    return null;
  }

  static Uri _appendParams(Uri uri, Map<String, String> params) {
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...params,
    });
  }

  static Future<String?> _requestRedirect(Uri uri) async {
    try {
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final headerRedirect = response.headers['location'];
      if (headerRedirect != null && headerRedirect.isNotEmpty) {
        return headerRedirect;
      }

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return _parseRedirectUrl(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('RazorpayPaymentHelper._requestRedirect: $e');
      }
    }
    return null;
  }

  static String? _parseRedirectUrl(String body) {
    if (body.contains(AppConstants.baseUrl) && body.contains('flag')) {
      if (body.trim().startsWith('http')) {
        return body.trim();
      }
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final content = decoded['content'];
        if (content is String && content.contains('http')) {
          return content;
        }
        if (content is Map<String, dynamic>) {
          return content['redirect_url']?.toString() ??
              content['callback']?.toString() ??
              content['url']?.toString();
        }
        return decoded['redirect_url']?.toString();
      }
    } catch (_) {}

    return null;
  }

  static void _dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _paymentCompleter = null;
    _paymentUrl = '';
    _orderData = null;
    _onRedirect = null;
  }
}
