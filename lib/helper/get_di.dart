import 'dart:convert';
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/api/remote/client_api.dart';
import 'package:demandium/common/models/language_model.dart';
import 'package:demandium/utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:demandium/feature/splash/repository/splash_repo.dart';
import 'package:demandium/feature/home/repository/banner_repo.dart';
import 'package:demandium/feature/home/repository/campaign_repo.dart';
import 'package:demandium/feature/home/repository/advertisement_repo.dart';
import 'package:demandium/feature/auth/repository/auth_repo.dart';
import 'package:demandium/feature/location/repository/location_repo.dart';
import 'package:demandium/feature/cart/repository/cart_repo.dart';
import 'package:demandium/feature/search/repository/search_repo.dart';
import 'package:demandium/feature/profile/repository/user_repo.dart';
import 'package:demandium/feature/area/repository/service_area_repository.dart';
import 'package:demandium/feature/wallet/repository/wallet_repo.dart';
import 'package:demandium/feature/loyalty_point/repository/loyalty_point_repo.dart';
import 'package:demandium/feature/coupon/repository/coupon_repo.dart';
import 'package:demandium/feature/create_post/repository/create_post_repo.dart';
import 'package:demandium/feature/provider/repository/provider_booking_repo.dart';
import 'package:demandium/feature/html/repository/html_repo.dart';
import 'package:demandium/feature/service/repository/service_details_repo.dart';
import 'package:demandium/feature/review/repo/submit_review_repo.dart';
import 'package:demandium/feature/checkout/repo/schedule_repo.dart';
import 'package:demandium/feature/booking/repo/service_booking_repo.dart';
import 'package:demandium/feature/booking/repo/booking_details_repo.dart';
import 'package:demandium/feature/conversation/repo/conversation_repo.dart';
import 'package:demandium/feature/favorite/repository/my_favorite_repo.dart';
import 'package:demandium/feature/category/repository/category_repo.dart';
import 'package:demandium/feature/service/repository/service_repo.dart';
import 'package:demandium/feature/checkout/repo/checkout_repo.dart';
import 'package:demandium/feature/notification/repository/notification_repo.dart';
import 'package:demandium/feature/web_landing/repository/web_landing_repo.dart';
import 'package:demandium/feature/suggest_new_service/repository/suggest_service_repo.dart';

import 'package:demandium/feature/splash/controller/theme_controller.dart';
import 'package:demandium/feature/language/controller/localization_controller.dart';
import 'package:demandium/feature/splash/controller/splash_controller.dart';
import 'package:demandium/feature/auth/controller/auth_controller.dart';
import 'package:demandium/feature/location/controller/location_controller.dart';
import 'package:demandium/feature/profile/controller/user_controller.dart';
import 'package:demandium/feature/cart/controller/cart_controller.dart';
import 'package:demandium/feature/checkout/controller/schedule_controller.dart';
import 'package:demandium/feature/checkout/controller/checkout_controller.dart';
import 'package:demandium/feature/booking/controller/service_booking_controller.dart';
import 'package:demandium/feature/booking/controller/booking_details_controller.dart';
import 'package:demandium/feature/conversation/controller/conversation_controller.dart';
import 'package:demandium/feature/home/controller/banner_controller.dart';
import 'package:demandium/feature/home/controller/campaign_controller.dart';
import 'package:demandium/feature/home/controller/advertisement_controller.dart';
import 'package:demandium/feature/category/controller/category_controller.dart';
import 'package:demandium/feature/service/controller/service_controller.dart';
import 'package:demandium/feature/service/controller/service_details_controller.dart';
import 'package:demandium/feature/search/controller/search_controller.dart';
import 'package:demandium/feature/coupon/controller/coupon_controller.dart';
import 'package:demandium/feature/create_post/controller/create_post_controller.dart';
import 'package:demandium/feature/provider/controller/provider_booking_controller.dart';
import 'package:demandium/feature/provider/controller/nearby_provider_controller.dart';
import 'package:demandium/feature/favorite/controller/my_favorite_controller.dart';
import 'package:demandium/feature/area/controller/service_area_controller.dart';
import 'package:demandium/feature/notification/controller/notification_controller.dart';
import 'package:demandium/feature/bottomNav/controller/bottom_nav_controller.dart';
import 'package:demandium/feature/html/controller/webview_controller.dart';
import 'package:demandium/feature/wallet/controller/wallet_controller.dart';
import 'package:demandium/feature/loyalty_point/controller/loyalty_point_controller.dart';
import 'package:demandium/feature/review/controller/submit_review_controller.dart';
import 'package:demandium/feature/language/controller/language_controller.dart';
import 'package:demandium/feature/profile/controller/select_image_controller.dart';
import 'package:demandium/feature/web_landing/controller/web_landing_controller.dart';
import 'package:demandium/feature/suggest_new_service/controller/suggest_service_controller.dart';

late AppDatabase database;

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences);

  database = AppDatabase();

  Get.put(ApiClient(
    appBaseUrl: AppConstants.baseUrl,
    sharedPreferences: sharedPreferences,
  ));

  Get.lazyPut(() => SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => BannerRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CampaignRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => AdvertisementRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CartRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => SearchRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceAreaRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => WalletRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => LoyaltyPointRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CouponRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CreatePostRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ProviderBookingRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceDetailsRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SubmitReviewRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ScheduleRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceBookingRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => MyFavoriteRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CategoryRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CheckoutRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => WebLandingRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => SuggestServiceRepo(apiClient: Get.find()), fenix: true);

  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SplashController(splashRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AuthController(authRepo: Get.find()), fenix: true);
  Get.lazyPut(() => LocationController(locationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => UserController(userRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CartController(cartRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ScheduleController(scheduleRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CheckOutController(checkoutRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceBookingController(serviceBookingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsController(bookingDetailsRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CampaignController(campaignRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AdvertisementController(advertisementRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CategoryController(categoryRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceController(serviceRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceDetailsController(serviceDetailsRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AllSearchController(searchRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CouponController(couponRepo: Get.find()), fenix: true);
  Get.lazyPut(() => CreatePostController(createPostRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ProviderBookingController(providerBookingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => NearbyProviderController(providerBookingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => MyFavoriteController(myFavoriteRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceAreaController(serviceAreaRepo: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BottomNavController(), fenix: true);
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()), fenix: true);
  Get.lazyPut(() => WalletController(walletRepo: Get.find()), fenix: true);
  Get.lazyPut(() => LoyaltyPointController(loyaltyPointRepo: Get.find()), fenix: true);
  Get.lazyPut(() => SubmitReviewController(submitReviewRepo: Get.find()), fenix: true);
  Get.lazyPut(() => LanguageController(), fenix: true);
  Get.lazyPut(() => SelectImageController(), fenix: true);
  Get.lazyPut(() => WebLandingController(webLandingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => SuggestServiceController(suggestServiceRepo: Get.find()), fenix: true);

  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    Map<String, String> jsonValue = {};
    mappedJson.forEach((key, value) {
      jsonValue[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonValue;
  }

  return languages;
}
