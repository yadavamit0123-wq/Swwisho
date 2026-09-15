
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';



class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];
  List<CartModel> _initialCartList = [];
  bool _isLoading = false;
  bool _isCartLoading = false;
  double _amount = 0.0;
  final bool _isOthersInfoValid = false;
  bool _isButton = false;

  List<CartModel> get cartList => _cartList;
  List<CartModel> get initialCartList => _initialCartList;
  double get amount => _amount;
  bool get isLoading => _isLoading;
  bool get isCartLoading  => _isCartLoading ;
  bool get isOthersInfoValid => _isOthersInfoValid;

  bool get isButton => _isButton;


  List<ProviderData>? _providerList;
  List<ProviderData>? get  providerList=> _providerList;

  double _totalPrice = 0;
  double _pendingCost = 0;
  double _travelingCharge = 0;
  double get totalPrice => _totalPrice;
  double get pendingCost => _pendingCost;
  double get travelingCharge => _travelingCharge;
  set updateTotalPrice(double price) => _totalPrice = price;

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;

  bool _hasShownTravelFreeMessage = true;
  bool get hasShownTravelFreeMessage => _hasShownTravelFreeMessage;

  updateTravelingToastCondition(bool value){
    _hasShownTravelFreeMessage = value;
    update();
  }
  void showTravelingToast(bool value, dynamic minimumAmountForTravelingCharge){

    if(_hasShownTravelFreeMessage){

      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomPopScopeWidget(
            canPop: false,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(Images.warning, width: 70, height: 70),
                ),
                Text(
                  'Book ₹${minimumAmountForTravelingCharge ?? '1000'} or more and get travel & hygiene disposable charges free.'.tr, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomButton(
                    onPressed: (){
                      Get.back();
                      Get.back();
                    },
                    buttonText: "go_back".tr
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault,),

                TextButton(
                  onPressed: () {
                    Get.back();
                    },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(Dimensions.webMaxWidth, 45), padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                  ),
                  child: Text("yes_continue".tr, textAlign: TextAlign.center, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                ),

              ]),
            ),
          );
        },
      );
    }
    _hasShownTravelFreeMessage = value;
    update();
  }

  double _referralAmount = 0.0;
  double get referralAmount => _referralAmount;

  double _bookingAmountWithoutCoupon = 0.0;
  double _couponAmount = 0.0;

  bool _walletPaymentStatus = false;
  bool get walletPaymentStatus => _walletPaymentStatus;

  ProviderData? _selectedProvider;
  ProviderData? get selectedProvider => _selectedProvider;


  String subcategoryId ='';

  int selectedProviderIndex = -1;


  Future<void> getCartListFromServer({bool shouldUpdate = true}) async{

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: ()=>  cartRepo.getCartListFromServer<CacheResponseData>( source: DataSourceEnum.local),
      fetchFromClient: ()=> cartRepo.getCartListFromServer(source: DataSourceEnum.client),
      onResponse: (data, source) {

        final content = data is Map ? data['content'] : null;
        if (content is! Map) {
          return;
        }

        _cartList = [];
        final cartData = content['cart'] is Map ? content['cart']['data'] : null;
        if (cartData is List) {
          for (final cart in cartData) {
            try {
              if (cart is Map) {
                _cartList.add(CartModel.fromJson(Map<String, dynamic>.from(cart)));
              }
            } catch (_) {}
          }
        }

        _walletBalance = double.tryParse(content['wallet_balance']?.toString() ?? '') ?? _walletBalance;
        _totalPrice = double.tryParse(content['total_cost']?.toString() ?? '') ?? _totalPrice;
        _pendingCost = double.tryParse(content['pending_cost']?.toString() ?? '') ?? _pendingCost;
        _travelingCharge = double.tryParse(content['traveling_charge']?.toString() ?? '') ?? _travelingCharge;
        _referralAmount = double.tryParse(content['referral_amount']?.toString() ?? '') ?? _referralAmount;

        if(_cartList.isNotEmpty){
          if(_cartList[0].provider!=null){
            _selectedProvider = _cartList[0].provider;
          }
          subcategoryId = _cartList[0].subCategoryId;
        }

        update();
      },
    );
  }

  Future<void> removeCartFromServer(CartModel cart)async{
    _isLoading = true;
    try {
      Response response = await cartRepo.removeCartFromServer(cart.id);
      if(response.statusCode == 200){
        _cartList.remove(cart);
      }

      await getCartListFromServer(shouldUpdate: false);
    } catch (_) {
    } finally {
      _isLoading = false;
      update();
    }
  }


  Future<void> removeAllCartItem()async{
    Response response = await cartRepo.removeAllCartFromServer();
    if(response.statusCode == 200){
      _isLoading = false;
      getCartListFromServer(shouldUpdate: false);
    }
  }

  Future<void> updateCartQuantityToApi(String cartID, int quantity)async{
    _isCartLoading = true;
    update();


    try {
      Response response = await cartRepo.updateCartQuantity(cartID, quantity);
      final content = response.body is Map ? response.body['content'] : null;
      if(response.statusCode == 200 && content is Map){
        _cartList = [];
        final cartData = content['cart'] is Map ? content['cart']['data'] : null;
        if (cartData is List) {
          for (final cart in cartData) {
            try {
              if (cart is Map) {
                _cartList.add(CartModel.fromJson(Map<String, dynamic>.from(cart)));
              }
            } catch (_) {}
          }
        }

        _walletBalance = double.tryParse(content['wallet_balance']?.toString() ?? '') ?? _walletBalance;
        _totalPrice = double.tryParse(content['total_cost']?.toString() ?? '') ?? _totalPrice;
        _pendingCost = double.tryParse(content['pending_cost']?.toString() ?? '') ?? _pendingCost;
        _travelingCharge = double.tryParse(content['traveling_charge']?.toString() ?? '') ?? _travelingCharge;
        _referralAmount = double.tryParse(content['referral_amount']?.toString() ?? '') ?? _referralAmount;

        if(_cartList.isNotEmpty){
          if(_cartList[0].provider!=null){
           _selectedProvider = _cartList[0].provider;
          }
          subcategoryId = _cartList[0].subCategoryId;
        }
      }
    } catch (_) {
    } finally {
      _isCartLoading = false;
      update();
    }
  }

  Future<void> updateProvider(ProviderData? providerData)async{

    _isCartLoading = true;
    update();
    _selectedProvider = providerData;

    Response response = await cartRepo.updateProvider(providerData?.id ?? "");
    if(response.statusCode == 200){
      await getCartListFromServer();
      Get.find<ScheduleController>().buildSchedule(scheduleType: ScheduleType.asap);
    }else{

    }
    _isCartLoading = false;
    update();
  }


  void removeFromCartVariation(CartModel? cartModel) {
    if(cartModel == null) {
      _initialCartList = [];
    }else{
      _initialCartList.remove(cartModel);
      update();
    }
  }

  void removeFromCartList(int cartIndex) {
    _cartList[cartIndex].quantity = _cartList[cartIndex].quantity - 1;
    update();
  }

  void updateQuantity(int index, bool isIncrement) {
    if(isIncrement){
      _initialCartList[index].quantity += 1;
      _totalPrice = _totalPrice + _initialCartList[index].totalCost;
    }else{
      if(_initialCartList[index].quantity > -1) {
        _initialCartList[index].quantity -= 1;
        _totalPrice = _totalPrice - _initialCartList[index].totalCost;
      }
    }
    _isButton = _isQuantity();
    update();
  }

 bool _isQuantity( ) {
    int count = 0;
    for (var cart in _initialCartList) {
      count += cart.quantity;
    }
    return count > 0;
  }



  void addDataToCart(){
    if(_cartList.isNotEmpty && _initialCartList.first.subCategoryId != _cartList.first.subCategoryId) {
      Get.back();
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: "are_you_sure_to_reset".tr,
        description: 'you_have_service_from_other_sub_category'.tr,
        onYesPressed: () async {
          _initialCartList.removeWhere((cart) => cart.quantity < 1);
          _cartList = _initialCartList;

          update();
          onDemandToast("successfully_added_to_cart".tr,Colors.green);
          Get.back();
        },
      ));
    }else{
      update();
      onDemandToast("successfully_added_to_cart".tr,Colors.green);
      Get.back();
    }

  }

  Future<void> addMultipleCartToServer({bool fromServiceCenterDialog = true, required String providerId}) async {
    _isLoading = true;
    update();
    _replaceCartList();

    if(_initialCartList.isEmpty || _cartList.isEmpty){
      _isLoading = false;
      update();
      return;
    }

    if(_initialCartList.first.subCategoryId != _cartList.first.subCategoryId){
      Get.back();
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: "are_you_sure_to_reset".tr,
        description: 'you_have_service_from_other_sub_category'.tr,
        onNoPressed: (){
          Get.back();
        },
        onYesPressed: () async {
          Get.back();
          Get.dialog(const CustomLoader(), barrierDismissible: false,);
          bool succeeded = false;
          try {
            await cartRepo.removeAllCartFromServer();
            if(_initialCartList.isNotEmpty){
              for (int index=0; index<_initialCartList.length;index++){
                await addToCartApi(_initialCartList[index], providerId: providerId);
              }
            }
            await getCartListFromServer();
            succeeded = true;
          } catch (_) {
          } finally {
            _isLoading = false;
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }
            update();
          }
          if(succeeded && fromServiceCenterDialog){
            customSnackBar("successfully_added_to_cart".tr,type : ToasterMessageType.success);
          } else if (!succeeded) {
            customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
          }
        },
      ));
    }
    else{
      try {
        await cartRepo.removeAllCartFromServer();
        if(_cartList.isNotEmpty){
          for (int index=0; index<_cartList.length;index++){
            await addToCartApi(_cartList[index], providerId: providerId);
          }
        }

        if(fromServiceCenterDialog){
          Get.back();
          customSnackBar("successfully_added_to_cart".tr,type : ToasterMessageType.success);
        }
      } catch (_) {
        customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      }
    }
    _isLoading = false;
    update();
  }

  Future<void> addToCartApi(CartModel cartModel, {required String providerId})async{

    if( providerId!= ""){
     await cartRepo.addToCartListToServer(CartModelBody(
        serviceId:cartModel.service!.id,
        categoryId: cartModel.categoryId,
        variantKey: cartModel.variantKey,
        quantity: cartModel.quantity.toString(),
        subCategoryId: cartModel.subCategoryId,
        providerId: providerId,
        guestId: Get.find<SplashController>().getGuestId(),
      ));
    }else{
       await cartRepo.addToCartListToServer(CartModelBody(
        serviceId:cartModel.service!.id,
        categoryId: cartModel.categoryId,
        variantKey: cartModel.variantKey,
        quantity: cartModel.quantity.toString(),
        subCategoryId: cartModel.subCategoryId,
        guestId: Get.find<SplashController>().getGuestId(),
      ));
    }
  }


  void removeAllAndAddToCart(CartModel cartModel) {
    _cartList = [];
    _cartList.add(cartModel);
    _amount = cartModel.discountedPrice.toDouble() * cartModel.quantity;
    update();
  }

  int isAvailableInCart(CartModel cartModel, Service service) {
    int index = -1;
    final serviceId = service.id ?? '';
    if (serviceId.isEmpty) {
      return index;
    }

    for (var cart in _cartList) {
      if(cart.service != null){
        if((cart.service!.id ?? '').contains(serviceId)) {
          if(cart.variantKey == cartModel.variantKey) {
            index = _cartList.indexOf(cart);
            break;
          }
        }
      }
    }
    return index;
  }

  void _addInitialCartItem({
    required Service service,
    required String variantKey,
    required num price,
  }) {
    final serviceId = service.id ?? '';
    if (serviceId.isEmpty || variantKey.isEmpty) {
      return;
    }

    var cartModel = CartModel(
      serviceId,
      serviceId,
      service.categoryId ?? '',
      service.subCategoryId ?? '',
      variantKey,
      price,
      0,
      0, 0, 0, 0, 0, 0, 0,
      "",
      0,
      service.tax ?? 0,
      price,
      service,
    );

    final index = isAvailableInCart(cartModel, service);
    if (index != -1) {
      cartModel = cartModel.copyWith(
        id: _cartList[index].id,
        quantity: _cartList[index].quantity,
      );
    }
    _initialCartList.add(cartModel);
  }

  setInitialCartList(Service service) {
    _totalPrice = 0;
    _pendingCost = 0;
    _travelingCharge = 0;
    _initialCartList = [];

    final zoneVariations = service.variationsAppFormat?.zoneWiseVariations ?? [];
    if (zoneVariations.isNotEmpty) {
      for (final variation in zoneVariations) {
        final variantKey = variation.variantKey ?? variation.variantName ?? '';
        if (variantKey.isEmpty) {
          continue;
        }
        _addInitialCartItem(
          service: service,
          variantKey: variantKey,
          price: variation.price ?? service.variationsAppFormat?.defaultPrice ?? 0,
        );
      }
    }

    if (_initialCartList.isEmpty) {
      for (final variation in service.variations ?? <Variations>[]) {
        final variantKey = variation.variantKey ?? variation.variant ?? '';
        if (variantKey.isEmpty) {
          continue;
        }
        _addInitialCartItem(
          service: service,
          variantKey: variantKey,
          price: variation.price ?? 0,
        );
      }
    }

    if (_initialCartList.isEmpty) {
      final defaultPrice = service.variationsAppFormat?.defaultPrice ?? 0;
      if (defaultPrice > 0) {
        _addInitialCartItem(
          service: service,
          variantKey: 'default',
          price: defaultPrice,
        );
      }
    }

    _isButton = false;
    update();
  }

  List<CartModel> _replaceCartList() {
    _initialCartList.removeWhere((cart) => cart.quantity < 0);

    for (var initCart in _initialCartList) {
      _cartList.removeWhere((cart) => cart.id.contains(initCart.id) && cart.variantKey.contains(initCart.variantKey));
    }
    _cartList.addAll(_initialCartList);
    _cartList.removeWhere((element) => element.quantity == 0);

    return _cartList;
  }

  Future<void> getProviderBasedOnSubcategory(String subcategoryId,bool reload) async {

    if(reload || _providerList == null){
      _providerList = null;
    }
    Response response = await cartRepo.getProviderBasedOnSubcategory(subcategoryId);
    if (response.statusCode == 200) {
      _providerList = [];
      List<dynamic> list =  response.body['content'];

      for (var element in list) {
        providerList!.add(ProviderData.fromJson(element));
      }

      if(_selectedProvider != null && _providerList != null && _providerList!.isNotEmpty){
        for(int i = 0 ; i <_providerList!.length ; i ++ ){
          if(_selectedProvider?.id == _providerList![i].id){
            selectedProviderIndex =i;
          }
        }
      }else{
        selectedProviderIndex = -1;
      }
    } else {
      _providerList = [];
    }
    update();
  }

  void updateProviderSelectedIndex(int index){
    selectedProviderIndex = index;
    update();
  }

  void updatePreselectedProvider(ProviderData? providerData, {bool shouldUpdate = true}){
   _selectedProvider = providerData;

   if(shouldUpdate){
     update();
   }

  }


  void updateWalletPaymentStatus(bool status, {bool shouldUpdate = true}){
    _walletPaymentStatus = status;

    if(shouldUpdate){
      update();
    }
  }

  updateBookingAmountWithoutCoupon(){
    _couponAmount = CheckoutHelper.calculateDiscount(cartList: _cartList, discountType: DiscountType.coupon);
    _bookingAmountWithoutCoupon =CheckoutHelper.calculateTotalAmountWithoutCoupon(cartList: _cartList);
  }


  bool isOpenPartialPaymentPopup = true;




  Future<void> openWalletPaymentConfirmDialog() async {
    bool initialCheck;
    bool checkAfterUsingCoupon;

    if(_bookingAmountWithoutCoupon > walletBalance){
      initialCheck = true;
    }else{
      initialCheck = false;
    }
    if(_bookingAmountWithoutCoupon > (walletBalance + _couponAmount)){
      checkAfterUsingCoupon =  true;
    }else{
      checkAfterUsingCoupon = false;
    }

    if(initialCheck != checkAfterUsingCoupon && walletPaymentStatus && isOpenPartialPaymentPopup){
      showGeneralDialog(barrierColor: Colors.black.withValues(alpha: 0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Center(
                child: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor
                    ),

                    child: Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        const WalletPaymentConfirmDialog(),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: (){
                            Get.back();
                            updateWalletPaymentStatus(false);
                          },
                          icon :  const Icon(Icons.cancel),color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: Get.context!,
        pageBuilder: (context, animation1, animation2){
          return Container();
        },
      );
    }
  }


  void showMinimumAndMaximumOrderValueToaster() {
    ConfigModel configModel = Get.find<SplashController>().configModel;

    Get.closeAllSnackbars();

    if(configModel.content!.minBookingAmount !=0 && configModel.content!.minBookingAmount! > _totalPrice && _cartList.isNotEmpty){
      customSnackBar("message",
        customWidget: Row(children: [
          Icon(Icons.circle, color: Colors.white.withValues(alpha: 0.8),size: 16,),
          Text("  ${'minimum_booking_amount'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content!.minBookingAmount!)}",
            style: robotoRegular.copyWith(color: Colors.white),
          ),
        ],),
      );
    }else{
      if(configModel.content!.maxBookingAmount !=0 && configModel.content!.maxBookingAmount! < _totalPrice &&  _cartList.isNotEmpty){
        customSnackBar("message",
          customWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Icon(Icons.warning_outlined, color: Theme.of(Get.context!).cardColor.withValues(alpha: 0.6),size: 16,),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                Flexible(child: Text(" ${'maximum_order_amount_exceed'.tr} ""(${'${'maximum_order_amount'.tr}'
                    ' ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content!.maxBookingAmount!)}'}) ${"admin_will_verify_this_order".tr}",
                  style: robotoRegular.copyWith(color: Colors.white),
                )),
              ],),
            ],
          ),
        );
      }
    }
  }

  Future<void> rebook(String bookingId) async{
    cartRepo.addRebookToServer(bookingId);
  }

  String maskNumberWithoutCountryCode(String phoneNumber) {
    if (phoneNumber.length <= 6) {
      return phoneNumber;
    }
    String maskedNumber = phoneNumber.substring(0, phoneNumber.length - 6); // Keep initial digits

    maskedNumber += '***';
    maskedNumber += phoneNumber.substring(phoneNumber.length - 3);
    return maskedNumber;
  }

  bool checkProviderUnavailability(){
    return _cartList.isNotEmpty &&  _cartList[0].provider !=null &&
        (_cartList[0].provider?.serviceAvailability == 0 || _cartList[0].provider?.isActive== 0 || _cartList[0].provider?.nextBookingEligibility == false);
  }

  String? checkScheduleBookingAvailability(){

    if(Get.find<SplashController>().configModel.content?.scheduleBooking == 0){
      return 'schedule_booking_currently_unavailable'.tr ;
    }else if(_cartList.isNotEmpty &&  _cartList[0].provider != null && ( _cartList[0].provider?.scheduleBookingEligibility == false)){
      return 'schedule_booking_currently_unavailable_for_this_provider'.tr ;
    }else{
      return null;
    }
  }

  @override
  void dispose() {
    _hasShownTravelFreeMessage = true;
    super.dispose();
  }

}
