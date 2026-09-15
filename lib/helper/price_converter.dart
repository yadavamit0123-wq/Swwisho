import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class PriceConverter {

  static String getCurrency() {
    String currencySymbol = Get.find<SplashController>().configModel.content?.currencySymbol ?? "";
   return currencySymbol;
  }

  static String convertPrice(double? price, {int ? decimalPointCount,double? discount, String? discountType, bool isShowLongPrice = false}) {
    double amount = price ?? 0;
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        amount = amount - discount;
      }else if(discountType == 'percent') {
        amount = amount - ((discount / 100) * amount);
      }
    }
    bool isRightSide = Get.find<SplashController>().configModel.content?.currencySymbolPosition == 'right' && Get.find<LocalizationController>().isLtr == true;
    int decimalPoint = decimalPointCount ??
        int.tryParse(Get.find<SplashController>().configModel.content?.currencyDecimalPoint ?? '0') ?? 0;

    final formatted = '${isRightSide ? '' : getCurrency()}'
        '${amount.toStringAsFixed(decimalPoint)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? getCurrency() : ''}';

    return isShowLongPrice == true ? formatted : longToShortPrice(formatted);
  }

  static double convertWithDiscount(double price, double discount, String discountType) {
    if(discountType == 'amount' || discountType == 'mixed') {
      price = price - discount;
    }else if(discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }


  static double calculation(double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = discount * quantity;
    }else if(type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : getCurrency()} ${'off'.tr}';
  }
  static String percentageOrAmount(String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : getCurrency()} ${'off'.tr}';  }


  static Discount _getDiscount(List<ServiceDiscount>? serviceDiscountList, double? discountAmount, String? discountAmountType) {
    ServiceDiscount? serviceDiscount = (serviceDiscountList != null && serviceDiscountList.isNotEmpty) ?serviceDiscountList.first : null;
    if(serviceDiscount?.discount != null){
      final discount = serviceDiscount!.discount!;
      num getDiscount = discount.discountAmount ?? 0;
      final maxDiscount = discount.maxDiscountAmount;
      if(maxDiscount != null && getDiscount > maxDiscount && discount.discountType == 'percent') {
        getDiscount = maxDiscount;
      }
      discountAmount = ((discountAmount ?? 0) + getDiscount).toDouble();
      discountAmountType = discount.discountAmountType ?? discountAmountType;
    }
    return Discount(discountAmount: discountAmount, discountAmountType: discountAmountType);
  }

 static Discount discountCalculation(Service service, {bool addCampaign = false}) {
    double? discountAmount = 0;
    String? discountAmountType;

    if(service.serviceDiscount != null && service.serviceDiscount!.isNotEmpty) {

      Discount discount =  _getDiscount(service.serviceDiscount, discountAmount, discountAmountType);
      discountAmount = discount.discountAmount;

      discountAmountType = discount.discountAmountType;


    }else if(service.campaignDiscount != null && service.campaignDiscount!.isNotEmpty && addCampaign) {

      Discount discount =  _getDiscount(service.campaignDiscount, discountAmount, discountAmountType);
      discountAmount = discount.discountAmount;
      discountAmountType = discount.discountAmountType;
    } else{
      if(service.category?.categoryDiscount != null && service.category!.categoryDiscount!.isNotEmpty) {
        Discount discount =  _getDiscount(service.category?.categoryDiscount, discountAmount, discountAmountType);
        discountAmount = discount.discountAmount;
        discountAmountType = discount.discountAmountType;

      }else if(service.category?.campaignDiscount != null && service.category!.campaignDiscount!.isNotEmpty && addCampaign){

        Discount discount =  _getDiscount(service.category?.campaignDiscount, discountAmount, discountAmountType);
        discountAmount = discount.discountAmount;
        discountAmountType = discount.discountAmountType;

      }
    }

    return Discount(discountAmount: discountAmount, discountAmountType: discountAmountType);
  }

  static double getDiscountToAmount(Discount discount, double amount) {

    double amount0 = 0;
    final discountValue = (discount.discountAmount ?? 0).toDouble();
    if(discount.discountAmountType == 'percent') {
     amount0 = (amount * discountValue) / 100.0 ;

     final maxDiscount = discount.maxDiscountAmount?.toDouble();
     if(maxDiscount != null && amount0 > maxDiscount) {
       amount0 = maxDiscount;
     }
    }else{
      amount0 = discountValue;
    }
    return amount0;

  }

  static String longToShortPrice(String price){
    return price.length > 15 ?
    "${price.substring(0, 12)}....${price.substring(price.length - 1,price.length)}":
    price;
  }
}