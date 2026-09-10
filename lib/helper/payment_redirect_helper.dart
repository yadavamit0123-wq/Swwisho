import 'dart:convert';

import 'package:demandium/utils/core_export.dart';
import 'package:uuid/uuid.dart';

class PaymentRedirectHelper {
  static Future<void> handleRedirect(String url, String fromPage) async {
    bool isSuccess = url.contains('success') && url.contains(AppConstants.baseUrl) && url.contains('flag');
    bool isFailed = url.contains('fail') && url.contains(AppConstants.baseUrl) && url.contains('flag');
    bool isCancel = url.contains('cancel') && url.contains(AppConstants.baseUrl) && url.contains('flag');

    if (isSuccess) {
      if (fromPage == 'checkout') {
        String token = StringParser.parseString(url, 'token');
        Get.find<CartController>().getCartListFromServer();
        Get.back();
        Get.offNamed(RouteHelper.getCheckoutRoute(RouteHelper.checkout, 'complete', 'null', token: token));
      } else if (fromPage == 'custom-checkout') {
        Get.offNamed(RouteHelper.getOrderSuccessRoute('success'));
      } else if (fromPage == 'add-fund') {
        Get.back();
        String uuid = const Uuid().v1();
        Get.offNamed(RouteHelper.getMyWalletScreen(flag: 'success', token: uuid));
      } else if (fromPage == 'switch-payment-method') {
        Get.back();
        customSnackBar(
          'your_payment_confirm_successfully'.tr,
          toasterTitle: 'payment_status'.tr,
          type: ToasterMessageType.success,
          duration: 4,
        );
      } else if (fromPage == 'repeat-booking') {
        Get.back();

        String? subBookingId;
        String? token = StringParser.parseString(url, 'token');

        try {
          subBookingId = StringParser.parseString(utf8.decode(base64Url.decode(token)), 'booking_repeat_id');
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        if (subBookingId != null) {
          Get.find<BookingDetailsController>().getSubBookingDetails(bookingId: subBookingId);
        }
        customSnackBar('paid_successfully'.tr, type: ToasterMessageType.success);
      }
    } else if (isFailed || isCancel) {
      if (fromPage == 'add-fund') {
        Get.offNamed(RouteHelper.getMyWalletScreen(flag: 'failed'));
      } else if (fromPage == 'repeat-booking') {
        Get.back();
        customSnackBar('payment_failed_try_again'.tr, type: ToasterMessageType.error, showDefaultSnackBar: false);
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute('fail'));
      }
    }
  }
}
