import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class CartSummery extends StatefulWidget {
  const CartSummery({super.key}) ;

  @override
  State<CartSummery> createState() => _CartSummeryState();
}

class _CartSummeryState extends State<CartSummery> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // step 1 add to cart -> /api/v1/customer/cart/add
  // step 2 cart list -> /api/v1/customer/cart/list?limit=100&offset=1&&guest_id=4c7766a0-461f-11f1-94bc-41f38054e76c
  // step 3 online payment -> https://test.swwisho.com/payment?travelling_charge=189.0&payment_method=razor_pay&access_token=Y2I4MTg0MzgtOTc3MS00ZDYwLTgzOWUtYTcyZjBlNTkwODA5&zone_id=a0eac7ed-41da-41fa-a119-e9369bba2c99&service_schedule=2026-05-08 15:00:00&service_address_id=&callback=https://test.swwisho.com&service_address=eyJpZCI6Im51bGwiLCJhZGRyZXNzX3R5cGUiOiJvdGhlcnMiLCJhZGRyZXNzX2xhYmVsIjoiaG9tZSIsImNvbnRhY3RfcGVyc29uX25hbWUiOiJVc2V0IFVzZXIiLCJjb250YWN0X3BlcnNvbl9udW1iZXIiOiIrOTE5ODc2NTQzMjEwIiwiYWRkcmVzcyI6IkgyM1YrVkhDLCBLdW1iaGVmYWwsIE1haGFyYXNodHJhIDQyMjYwMSwgSW5kaWEiLCJsYXQiOiIxOS41NTQzOTQzMDgwNTg1IiwibG9uIjoiNzQuMDQ1Mjc0Mjk0OTEyODIiLCJjaXR5IjoiS3VtYmhlZmFsIiwiemlwX2NvZGUiOiI0MjI2MDEiLCJjb3VudHJ5IjoiSW5kaWEiLCJ6b25lX2lkIjoiYTBlYWM3ZWQtNDFkYS00MWZhLWExMTktZTkzNjliYmEyYzk5IiwiX21ldGhvZCI6bnVsbCwic3RyZWV0IjoiIiwiaG91c2UiOiIiLCJmbG9vciI6bnVsbCwiYXZhaWxhYmxlX3NlcnZpY2VfY291bnQiOjYwfQ==&new_user_info=bnVsbA==&is_partial=0&payment_platform=app&service_location=customer
  // step 4 pay after service -> /api/v1/customer/booking/request/send

  // step 5 My booking list -> /api/v1/customer/booking?limit=10&offset=1&booking_status=all&service_type=all
  // step 6 My booking details -> https://test.swwisho.com/api/v1/customer/booking/e343abd0-46bb-4900-951f-1560df5633e4

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(builder: (checkoutController){
      return GetBuilder<ScheduleController>(builder: (scheduleController){
        return GetBuilder<CartController>(
          initState: (state) {
            state.controller?.updateTravelingToastCondition(true);
          },
            builder: (cartController){

              int scheduleDaysCount = scheduleController.scheduleDaysCount > 0 ? scheduleController.scheduleDaysCount : 1;

              ConfigModel configModel = Get.find<SplashController>().configModel;
              List<CartModel> cartList = cartController.cartList;
              num pendingCost = -(cartController.pendingCost);
              double travelingCharge = double.parse(configModel.content?.travelingCharge?.toString() ?? "0.0");
              // double travelingCharge = CheckoutHelper.calculateTravelingCharge(cartList: cartList);
              double gstOnCommission = CheckoutHelper.calculateGstOnCommission(cartList: cartList);
              double commission = CheckoutHelper.calculateCommission(cartList: cartList);
              double minimumAmountForTravelingCharge = (configModel.content?.minimumAmountForTravelingCharge ?? 0.0);
              bool walletPaymentStatus = cartController.walletPaymentStatus;
              int applicableCouponCount = CheckoutHelper.getNumberOfDaysForApplicableCoupon(pickedScheduleDays:scheduleDaysCount) ?? 1;
              double additionalCharge = CheckoutHelper.getAdditionalCharge();
              bool isPartialPayment = CheckoutHelper.checkPartialPayment(walletBalance: cartController.walletBalance, bookingAmount: cartController.totalPrice);
              double paidAmount = CheckoutHelper.calculatePaidAmount(walletBalance: cartController.walletBalance, bookingAmount: cartController.totalPrice);
              double subTotalPrice =  CheckoutHelper.calculateSubTotal(cartList: cartList, daysCount: scheduleDaysCount);
              double disCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.general, daysCount: scheduleDaysCount);
              double campaignDisCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.campaign, daysCount: scheduleDaysCount);
              double couponDisCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.coupon, daysCount: applicableCouponCount);
              double referDisCount = cartController.referralAmount;
              // double vat =  CheckoutHelper.calculateVat(cartList: cartList, daysCount: scheduleDaysCount);
              double grandTotal = CheckoutHelper.calculateGrandTotal(cartList: cartList, referralDiscount: referDisCount, daysCount: scheduleDaysCount, pendingAmount: pendingCost);
              double dueAmount = CheckoutHelper.calculateDueAmount(cartList: cartList, walletPaymentStatus: walletPaymentStatus, walletBalance:cartController.walletBalance, bookingAmount: cartController.totalPrice, referralDiscount: referDisCount, daysCount: scheduleDaysCount, pendingAmount: pendingCost);

              gstOnCommission += commission;

              Future.delayed(const Duration(milliseconds: 200), (){
                cartController.updateTotalPrice = grandTotal;
                cartController.update();
              });


              if (cartController.hasShownTravelFreeMessage && grandTotal < minimumAmountForTravelingCharge) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cartController.showTravelingToast(false, minimumAmountForTravelingCharge);
                });
              }

              if(grandTotal < minimumAmountForTravelingCharge){
                checkoutController.travelingChargeForPayment = travelingCharge;
                grandTotal += travelingCharge;
              }else{
                checkoutController.travelingChargeForPayment = 0.0;
                travelingCharge = 0.0;
              }

              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
                    child: Text( 'cart_summary'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault))
                ),

                Padding( padding: const EdgeInsets.all( Dimensions.paddingSizeDefault),
                  child: Column( children: [
                    ListView.builder(
                      itemCount: cartList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        double totalCost = (cartList.elementAt(index).serviceCost.toDouble() * cartList.elementAt(index).quantity) * scheduleDaysCount;
                        return Column( mainAxisAlignment: MainAxisAlignment.start,  crossAxisAlignment: CrossAxisAlignment.start, children: [
                          RowText(title: cartList.elementAt(index).service!.name!, quantity: cartList.elementAt(index).quantity, price: totalCost),
                          SizedBox( width:Get.width / 2.5,
                            child: Text( cartList.elementAt(index).variantKey,
                              style: robotoMedium.copyWith( color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .4), fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault,)
                        ]);
                      },
                    ),

                    Divider(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    RowText(title: 'sub_total'.tr, price: subTotalPrice),
                    RowText(title: 'discount'.tr, price: disCount),
                    RowText(title: 'campaign_discount'.tr, price: campaignDisCount),
                    RowText(title: 'coupon_discount'.tr, price: couponDisCount),
                    if(referDisCount > 0)
                      RowText(title: 'referral_discount'.tr, price: referDisCount),
                    // RowText(title: "vat".tr, price: vat),

                    (configModel.content?.additionalChargeLabelName != "" && configModel.content?.additionalCharge == 1) ?
                    GetBuilder<CheckOutController>(builder: (controller){
                      return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        Expanded(
                          child: Row(children: [
                            Flexible(child: Text(configModel.content?.additionalChargeLabelName ?? "", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),overflow: TextOverflow.ellipsis,)),

                          ],),
                        ),
                        Text("(+) ${PriceConverter.convertPrice( additionalCharge, isShowLongPrice: true)}", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),)
                      ],);
                    }): const SizedBox(),

                    if(pendingCost > 0)
                    RowText(title: 'pending_amount'.tr, price: double.parse(pendingCost.toString())),
                    if(travelingCharge > 0)
                    RowText(title: 'traveling_charge'.tr, price: double.parse(travelingCharge.toString())),

                    RowText(title: 'fees_and_taxes'.tr, price: double.parse(gstOnCommission.toString())),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Divider(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6)),
                    ),

                    RowText(title:'grand_total'.tr , price: grandTotal),
                    (Get.find<CartController>().walletPaymentStatus) ? RowText(title:'paid_by_wallet'.tr , price: paidAmount) : const SizedBox(),
                    (Get.find<CartController>().walletPaymentStatus && isPartialPayment) ? RowText(title:'due_amount'.tr , price: dueAmount) : const SizedBox(),
                  ]),
                ),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: ConditionCheckBox(
                    checkBoxValue: checkoutController.acceptTerms,
                    onTap: (bool? value){
                      checkoutController.toggleTerms();
                    },
                  ),
                ),

              ]);
            }
        );
      });
    });
  }
}
