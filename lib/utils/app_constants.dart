import 'package:demandium/common/enums/enums.dart';
import 'package:demandium/common/models/language_model.dart';
import 'package:demandium/utils/images.dart';

class AppConstants {
  static const String appName = 'Swwisho';
  static String appVersion = '1.0.0';
  static const String baseUrl = 'https://swwisho.com';

  /// Meta (Facebook) SDK — replace client token from Meta Developer Console.
  static const String facebookAppId = '894478949810159';
  static const String facebookClientToken = 'REPLACE_WITH_META_CLIENT_TOKEN';
  static const String topic = 'demandium';
  static const bool avoidMaintenanceMode = false;
  static const LocalCachesTypeEnum cachesType = LocalCachesTypeEnum.all;

  static const String localizationKey = 'X-localization';
  static const String zoneId = 'zoneId';
  static const String guestId = 'guest_id';

  static Map<String, String> configHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer null',
  };

  static const String configUri = '/api/v1/customer/config';
  static const String categoryUrl = '/api/v1/customer/category?status=active';
  static const String bannerUri = '/api/v1/customer/banner?limit=10&offset=1';
  static const String campaignUri = '/api/v1/customer/campaign?limit=10&offset=1';
  static const String advertisementList = '/api/v1/customer/advertisement/ads-list?limit=10&offset=1';
  static const String allServiceUri = '/api/v1/customer/service';
  static const String popularServiceUri = '/api/v1/customer/service/popular';
  static const String trendingServiceUri = '/api/v1/customer/service/trending';
  static const String recommendedServiceUri = '/api/v1/customer/service/recommended';
  static const String recentlyViewedServiceUri = '/api/v1/customer/service/recently-viewed';
  static const String featheredCategoryUri = '/api/v1/customer/service/feathered-categories';
  static const String recommendedSearchUri = '/api/v1/customer/service/recommended-search';
  static const String updateIsFavoriteStatusUri = '/api/v1/customer/service/favorite';
  static const String offerListUri = '/api/v1/customer/service/offers';
  static const String serviceBasedOnSubCategory = '/api/v1/customer/service/sub-category/';
  static const String itemsBasedOnCampaignId = '/api/v1/customer/campaign/data/items?campaign_id=';
  static const String subCategoryUri = '/api/v1/customer/category/childes?limit=20&offset=1&id=';
  static const String serviceDetailsUri = '/api/v1/customer/service/detail';
  static const String getServiceReviewList = '/api/v1/customer/service/review/';
  static const String searchUri = '/api/v1/customer/service/search';
  static const String searchSuggestion = '/api/v1/customer/service/search-suggestion';
  static const String webLandingContents = '/api/v1/customer/landing/contents';
  static const String getSuggestedServiceList = '/api/v1/customer/service/suggestion/list';
  static const String submitNewServiceRequest = '/api/v1/customer/service/suggestion/submit';
  static const String getProviderList = '/api/v1/customer/provider/list';
  static const String getProviderDetails = '/api/v1/customer/provider/details';
  static const String updateFavoriteProviderStatus = '/api/v1/customer/provider/favorite';
  static const String getFavoriteServiceList = '/api/v1/customer/service/favorite/list';
  static const String getFavoriteProviderList = '/api/v1/customer/provider/favorite/list';
  static const String removeFavoriteService = '/api/v1/customer/service/favorite/remove';
  static const String removeFavoriteProvider = '/api/v1/customer/provider/favorite/remove';
  static const String getZoneListApi = '/api/v1/customer/zone/list';
  static const String registerUri = '/api/v1/customer/auth/registration';
  static const String loginUri = '/api/v1/customer/auth/login';
  static const String loginOut = '/api/v1/customer/auth/logout';
  static const String socialLoginUri = '/api/v1/customer/auth/social-login';
  static const String existingAccountCheck = '/api/v1/customer/auth/existing-account-check';
  static const String registerWithSocialMedia = '/api/v1/customer/auth/social-registration';
  static const String registerWithOtp = '/api/v1/customer/auth/registration-with-otp';
  static const String phoneOtpVerification = '/api/v1/customer/auth/phone-otp-verification';
  static const String firebaseOtpVerify = '/api/v1/customer/auth/firebase-auth-verify';
  static const String sendOtpForVerification = '/api/v1/customer/auth/send-otp';
  static const String sendOtpForForgetPassword = '/api/v1/customer/auth/forgot-password/send-otp';
  static const String verifyOtpForVerificationScreen = '/api/v1/customer/auth/otp-verification';
  static const String verifyOtpForForgetPasswordScreen = '/api/v1/customer/auth/forgot-password/otp-verification';
  static const String resetPasswordUri = '/api/v1/customer/auth/reset-password';
  static const String tokenUri = '/api/v1/customer/update/fcm-token';
  static const String updateZoneUri = '/api/v1/customer/update-zone';
  static const String customerInfoUri = '/api/v1/customer/info';
  static const String customerRemove = '/api/v1/customer/remove-account';
  static const String updateProfileUri = '/api/v1/customer/update/profile';
  static const String addToCart = '/api/v1/customer/cart/add';
  static const String getCartList = '/api/v1/customer/cart/list?limit=100&offset=1';
  static const String removeCartItem = '/api/v1/customer/cart/remove/';
  static const String removeAllCartItem = '/api/v1/customer/cart/data/empty';
  static const String updateCartQuantity = '/api/v1/customer/cart/update-quantity/';
  static const String updateCartProvider = '/api/v1/customer/cart/update/provider';
  static const String getProviderBasedOnSubcategory = '/api/v1/customer/cart/provider/list';
  static const String rebookApi = '/api/v1/customer/booking/rebook';
  static const String rebookAvailabilityApi = '/api/v1/customer/booking/rebook-availability-check';
  static const String placeRequest = '/api/v1/customer/booking/request/send';
  static const String bookingList = '/api/v1/customer/booking';
  static const String bookingDetails = '/api/v1/customer/booking';
  static const String subBookingDetails = '/api/v1/customer/booking/repeat/sub-booking';
  static const String bookingCancel = '/api/v1/customer/booking/status-update';
  static const String subBookingCancel = '/api/v1/customer/booking/repeat/sub-booking/cancel';
  static const String trackBooking = '/api/v1/customer/booking/track';
  static const String reschedule = '/api/v1/customer/booking/re-schedule';
  static const String bookingOfflinePayment = '/api/v1/customer/booking/offline-payment';
  static const String bookingSwitchPaymentMethod = '/api/v1/customer/booking/switch-payment-method';
  static const String offlinePaymentMethod = '/api/v1/customer/config/offline-payment-method-list';
  static const String digitalPaymentResponse = '/api/v1/customer/booking/payment-status';
  static const String addressUri = '/api/v1/customer/address';
  static const String zoneUri = '/api/v1/customer/config/get-zone-id';
  static const String geocodeUri = '/api/v1/customer/config/geocode-api';
  static const String searchLocationUri = '/api/v1/customer/config/place-api-autocomplete';
  static const String placeDetailsUri = '/api/v1/customer/config/place-api-details';
  static const String couponUri = '/api/v1/customer/coupon?limit=100&offset=1&status=all&coupon_type=all';
  static const String applyCoupon = '/api/v1/customer/coupon/apply';
  static const String removeCoupon = '/api/v1/customer/coupon/remove';
  static const String walletTransactionData = '/api/v1/customer/wallet/transactions';
  static const String bonusUri = '/api/v1/customer/wallet/bonus-list';
  static const String convertLoyaltyPointUri = '/api/v1/customer/loyalty-point/wallet-transfer';
  static const String loyaltyPointTransactionData = '/api/v1/customer/loyalty-point/transactions';
  static const String createCustomizedPost = '/api/v1/customer/custom-post/create';
  static const String getMyPostList = '/api/v1/customer/custom-post/list';
  static const String getInterestedProviderList = '/api/v1/customer/custom-post/bid/list';
  static const String getProviderBidDetails = '/api/v1/customer/custom-post/bid/details';
  static const String updatePostStatus = '/api/v1/customer/custom-post/bid/update-status';
  static const String updatePostInfo = '/api/v1/customer/custom-post/update-info';
  static const String createChannel = '/api/v1/customer/chat/create-channel';
  static const String getChannelListUrl = '/api/v1/customer/chat/channel-list';
  static const String searchChannelListUrl = '/api/v1/customer/chat/search-channel-list';
  static const String getConversation = '/api/v1/customer/chat/conversation';
  static const String sendMessage = '/api/v1/customer/chat/send-message';
  static const String notificationUri = '/api/v1/customer/notification';
  static const String serviceReview = '/api/v1/customer/review/submit';
  static const String bookingReviewList = '/api/v1/customer/review/list';
  static const String pages = '/api/v1/customer/config/pages';
  static const String changeLanguage = '/api/v1/customer/change-language';
  static const String addError404Url = '/api/v1/customer/error-url';
  static const String newsLetterSubscription = '/api/v1/customer/newsletter/subscribe';
  static const String regularBookingInvoiceUrl = '/booking/invoice/regular/';
  static const String repeatBookingInvoiceUrl = '/booking/invoice/repeat/';
  static const String singleRepeatBookingInvoiceUrl = '/booking/invoice/repeat/single/';

  static const String theme = 'demand_theme';
  static const String token = 'demand_token';
  static const String countryCode = 'demand_country_code';
  static const String languageCode = 'demand_language_code';
  static const String userPassword = 'demand_user_password';
  static const String userAddress = 'demand_user_address';
  static const String userNumber = 'demand_user_number';
  static const String userCountryCode = 'demand_user_country_code';
  static const String notification = 'demand_notification';
  static const String searchHistory = 'demand_search_history';
  static const String notificationCount = 'demand_notification_count';
  static const String acceptCookies = 'demand_accept_cookies';
  static const String cookiesManagement = 'demand_cookies_management';
  static const String initialLanguage = 'demand_initial_language';
  static const String onboardingScreen = 'demand_onboarding_screen';
  static const String referredBottomSheet = 'demand_referred_bottom_sheet';
  static const String lastIncompleteOfflineBookingId = 'demand_last_incomplete_offline_booking_id';
  static const String isContinueZone = 'demand_is_continue_zone';
  static const String walletAccessToken = 'demand_wallet_access_token';
  static const String bookingOtp = 'demand_booking_otp';

  static const double limitOfPickedImageSizeInMB = 2;
  static const double maxSizeOfASingleFile = 2;
  static const double maxLimitOfFileSentINConversation = 10;
  static const double maxLimitOfTotalFileSent = 5;

  static const List<String> identityTypeList = ['passport', 'driving_license', 'nid'];

  static const List<String> timeSlots = [
    '07:00 AM - 08:00 AM',
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
    '08:00 PM - 09:00 PM',
  ];

  static const List<Map<String, dynamic>> walletTransactionSortingList = [
    {'title': 'all', 'value': 'all'},
    {'title': 'add_fund', 'value': 'add_fund'},
    {'title': 'loyalty_point_earning', 'value': 'loyalty_point_earning'},
    {'title': 'booking_refund', 'value': 'booking_refund'},
    {'title': 'paid_by_wallet', 'value': 'paid_by_wallet'},
  ];

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.us, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.india, languageName: 'Hindi', countryCode: 'IN', languageCode: 'hi'),
    LanguageModel(imageUrl: Images.bn, languageName: 'Bangla', countryCode: 'BD', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.ar, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
  ];
}
