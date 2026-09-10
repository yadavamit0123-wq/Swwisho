import 'dart:convert';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CheckoutRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  CheckoutRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> placeBookingRequest({
    required String paymentMethod,
    required String zoneId,
    String? schedule,
    required String serviceAddressID,
    required AddressModel serviceAddress,
    int isPartial = 0,
    required String serviceType,
    required String bookingType,
    String? dates,
    SignUpBody? newUserInfo,
    required String serviceLocation,
  }) async {
    Map<String, dynamic> body = {
      'payment_method': paymentMethod,
      'zone_id': zoneId,
      'service_schedule': schedule,
      'service_address_id': serviceAddressID,
      'service_address': jsonEncode(serviceAddress.toJson()),
      'is_partial': isPartial,
      'service_type': serviceType,
      'booking_type': bookingType,
      'dates': dates,
      'guest_id': Get.find<SplashController>().getGuestId(),
      'service_location': serviceLocation,
    };
    if (newUserInfo != null) {
      body.addAll(newUserInfo.toJson());
    }
    return await apiClient.postData(AppConstants.placeRequest, body);
  }

  Future<Response> getPostDetails(String postID, String bidId) async {
    return await apiClient.getData('${AppConstants.getProviderBidDetails}?post_id=$postID&provider_id=$bidId');
  }

  Future<Response?> checkExistingUser({required String phone}) async {
    return await apiClient.postData(AppConstants.existingAccountCheck, {
      'phone_or_email': phone,
      'guest_id': Get.find<SplashController>().getGuestId(),
    });
  }

  Future<Response?> submitOfflinePaymentData({
    required String bookingId,
    required String offlinePaymentId,
    required dynamic offlinePaymentInfo,
    required int isPartialPayment,
  }) async {
    return await apiClient.postData(AppConstants.bookingOfflinePayment, {
      'booking_id': bookingId,
      'offline_payment_id': offlinePaymentId,
      'customer_information': offlinePaymentInfo,
      'is_partial': isPartialPayment,
    });
  }

  Future<Response?> switchPaymentMethod({
    required String bookingId,
    required String paymentMethod,
    String? offlinePaymentId,
    String? offlinePaymentInfo,
    int isPartial = 0,
  }) async {
    return await apiClient.postData(AppConstants.bookingSwitchPaymentMethod, {
      'booking_id': bookingId,
      'payment_method': paymentMethod,
      'offline_payment_id': offlinePaymentId,
      'customer_information': offlinePaymentInfo,
      'is_partial': isPartial,
    });
  }

  Future<Response> getOfflinePaymentMethod() async {
    return await apiClient.getData(AppConstants.offlinePaymentMethod);
  }

  Future<Response> getDigitalPaymentResponse({String? transactionId}) async {
    return await apiClient.getData('${AppConstants.digitalPaymentResponse}?transaction_id=$transactionId');
  }
}
