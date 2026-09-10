import 'package:demandium/feature/checkout/view/payment_screen.dart';
import 'package:demandium/helper/payment_redirect_helper.dart';
import 'package:demandium/helper/razorpay_payment_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

class DigitalPaymentHelper {
  static const String razorPayGateway = 'razor_pay';

  static String? extractGatewayFromUrl(String paymentUrl) {
    try {
      return Uri.parse(paymentUrl).queryParameters['payment_method'];
    } catch (_) {
      return null;
    }
  }

  static Future<void> launch({
    required String paymentGateway,
    required String paymentUrl,
    required String fromPage,
  }) async {
    if (!GetPlatform.isWeb && paymentGateway == razorPayGateway) {
      final handled = await RazorpayPaymentHelper.startPayment(
        paymentUrl: paymentUrl,
        onRedirect: (redirectUrl) => PaymentRedirectHelper.handleRedirect(redirectUrl, fromPage),
      );
      if (handled) {
        return;
      }
    }

    if (GetPlatform.isWeb) {
      html.window.open(paymentUrl, '_self');
    } else {
      Get.to(() => PaymentScreen(url: paymentUrl, fromPage: fromPage));
    }
  }

  static Future<void> launchFromUrl({
    required String paymentUrl,
    required String fromPage,
  }) {
    return launch(
      paymentGateway: extractGatewayFromUrl(paymentUrl) ?? '',
      paymentUrl: paymentUrl,
      fromPage: fromPage,
    );
  }
}
