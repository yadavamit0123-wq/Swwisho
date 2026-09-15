import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';



class CouponController extends GetxController implements GetxService{
  final CouponRepo couponRepo;
  CouponController({required this.couponRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  List<CouponModel>? _activeCouponList;
  List<CouponModel>? get activeCouponList => _activeCouponList;

  List<CouponModel>? _expiredCouponList;
  List<CouponModel>? get expiredCouponList => _expiredCouponList;

  int _selectedCouponIndex = -1;
  int get selectedCouponIndex => _selectedCouponIndex;


  TabController? voucherTabController;
  CouponTabState __couponTabCurrentState = CouponTabState.currentCoupon;
  CouponTabState get couponTabCurrentState => __couponTabCurrentState;

  Future<void> getCouponList({bool reload = true}) async {
    if(reload){
      _activeCouponList = null;
      _expiredCouponList = null;
    }

    try {
      Response response = await couponRepo.getCouponList();
      if (response.statusCode == 200) {
        _activeCouponList = [];
        _expiredCouponList = [];
        final content = response.body is Map ? response.body["content"] : null;
        if (content is Map) {
          _activeCouponList!.addAll(_parseCoupons(content['active_coupons']));
          _expiredCouponList!.addAll(_parseCoupons(content['expired_coupons']));
        }
      } else {
        _activeCouponList ??= [];
        _expiredCouponList ??= [];
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _activeCouponList ??= [];
      _expiredCouponList ??= [];
    }

    update();
  }

  List<CouponModel> _parseCoupons(dynamic section) {
    final coupons = <CouponModel>[];
    final data = section is Map ? section['data'] : (section is List ? section : null);
    if (data is List) {
      for (final item in data) {
        try {
          if (item is Map) {
            coupons.add(CouponModel.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {}
      }
    }
    return coupons;
  }

  Future<ResponseModel> applyCoupon(String  couponCode) async {
    _isLoading = true;
    update();

    try {
      Response response = await couponRepo.applyCoupon(couponCode);
      final message = (response.body is Map ? response.body['message'] : null)?.toString();

      if(response.statusCode == 200 && response.body is Map && response.body['response_code'] == 'coupon_applied_200'){

        final couponList = _activeCouponList ?? [];
        for( int i = 0 ; i < couponList.length ; i ++){
          if(couponList[i].couponCode == couponCode || (couponList[i].couponCode?.toLowerCase() == couponCode.toLowerCase())){
            couponList[i].isUsed = 1;
          }else{
            couponList[i].isUsed = 0;
          }
        }
        await Get.find<CartController>().getCartListFromServer();
        Get.find<CartController>().updateBookingAmountWithoutCoupon();

        return ResponseModel(true, message ?? 'success'.tr);
      }else{
        return ResponseModel(false, message ?? 'something_went_wrong'.tr);
      }
    } catch (_) {
      return ResponseModel(false, 'something_went_wrong'.tr);
    } finally {
      _isLoading = false;
      update();
    }
  }



  Future<void> removeCoupon({ int? index, bool fromCheckout = false}) async {
    _isLoading = true;
    update();
    Response response = await couponRepo.removeCoupon();
    if(response.statusCode == 200 && response.body['response_code'] == 'default_update_200'){
      await Get.find<CartController>().getCartListFromServer();
      if(!fromCheckout){
        Get.back();
      }
      customCouponSnackBar("removed".tr,  subtitle :"coupon_removed_successfully" );
      if(index!=null){
        _activeCouponList?[index].isUsed = 0;
      }

    }else{

      if(!fromCheckout){
        Get.back();
        customSnackBar(response.body['message'], type : ToasterMessageType.success);
      }
    }
    _isLoading = false;
    update();
  }



  void updateTabBar(CouponTabState couponTabState, {bool isUpdate = true}){
    __couponTabCurrentState = couponTabState;
    if(isUpdate){
      update();
    }
  }

  updateSelectedCouponIndex({int? index, bool shouldUpdate = true}){
    if( index !=null ){
      _selectedCouponIndex = index;
    }
    if(shouldUpdate){
      update();
    }
  }
}

enum CouponTabState {
  currentCoupon,
  usedCoupon
}