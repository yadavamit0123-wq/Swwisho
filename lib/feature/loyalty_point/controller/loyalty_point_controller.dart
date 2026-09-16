import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class LoyaltyPointController extends GetxController implements GetxService{

  final LoyaltyPointRepo loyaltyPointRepo;
  LoyaltyPointController({required this.loyaltyPointRepo});
  
  bool _isLoading= false;
  bool get isLoading => _isLoading;

  LoyaltyPointModel? loyaltyPointModel;
  List<LoyaltyPointTransactionData> listOfTransaction = [];

  TextEditingController loyaltyPointController = TextEditingController();


  Future<void> convertLoyaltyPoint() async {
    _isLoading = true;
    update();
    try {
      Response response = await loyaltyPointRepo.convertLoyaltyPoint(loyaltyPointController.text);
      if(response.statusCode == 200){
        loyaltyPointController.text='';
        await getLoyaltyPointData(1);
        Get.back();
        customSnackBar("point_converted_to_wallet_money".tr,type : ToasterMessageType.success);
      }
      else {
        ApiChecker.checkApi(response);
      }
    } catch (_) {}
    _isLoading = false;
    update();
  }

  Future<void> getLoyaltyPointData(int offset,{reload = false}) async {

    if(reload){
      loyaltyPointModel= null;
      update();
    }
    loyaltyPointController.text='';
    try {
      Response response = await loyaltyPointRepo.getLoyaltyPointData(offset);
      if(response.statusCode == 200 && response.body is Map){
        loyaltyPointModel = LoyaltyPointModel.fromJson(Map<String, dynamic>.from(response.body));

        final items = loyaltyPointModel?.content?.transactions?.data ?? [];
        if(offset!=1){
          listOfTransaction.addAll(items);
        }else{
          listOfTransaction = [];
          listOfTransaction.addAll(items);
        }
      }
      else {
        if (offset == 1) {
          loyaltyPointModel ??= LoyaltyPointModel(
            content: LoyaltyPointContent(loyaltyPoint: 0),
          );
          listOfTransaction = [];
        }
        if(response.statusCode != 200){
          ApiChecker.checkApi(response);
        }
      }
    } catch (_) {
      if (offset == 1) {
        loyaltyPointModel ??= LoyaltyPointModel(
          content: LoyaltyPointContent(loyaltyPoint: 0),
        );
        listOfTransaction = [];
      }
    }
    update();
  }

}