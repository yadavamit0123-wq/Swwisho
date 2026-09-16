import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class ServiceDetailsController extends GetxController implements GetxService{
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceDetailsController({required this.serviceDetailsRepo});

  Service? _service;
  bool? _isLoading;
  Service? get service => _service;
  bool get isLoading => _isLoading ?? false;


  ///discount and discount type based on category discount and service discount
  double? _serviceDiscount = 0.0;
  double get serviceDiscount => _serviceDiscount!;

  String? _discountType;
  String get discountType => _discountType!;

  ///call service details data based on service id
  Future<void> getServiceDetails(String serviceID,{String fromPage=""}) async {
    if (_service?.id != serviceID) {
      Service? cached;
      try {
        cached = Get.find<ServiceController>().findCachedService(serviceID);
      } catch (_) {}
      _service = cached;
      _isLoading = cached == null;
      update();
    }
    try {
      Response response = await serviceDetailsRepo.getServiceDetails(serviceID,fromPage);
      if (response.statusCode == 200 && response.body is Map && response.body['response_code'] == 'default_200') {
        final content = response.body['content'];
        if (content is Map) {
          _service = Service.fromJson(Map<String, dynamic>.from(content));
        }
      } else {
        if(response.statusCode != 200){
          ApiChecker.checkApi(response);
        }
      }
    } catch (_) {}
    _isLoading = false;

    update();
  }

  Future<void> getServiceDiscount() async {
    Service service = _service!;
    ///if category discount not null then calculate category discount
    if(service.campaignDiscount != null){
      ///service based campaign discount
      _serviceDiscount = service.campaignDiscount!.isNotEmpty ?  service.campaignDiscount!.elementAt(0).discount!.discountAmount!.toDouble(): 0.0;
      _discountType = service.campaignDiscount!.isNotEmpty ?  service.campaignDiscount!.elementAt(0).discount!.discountType!:'amount';
    }else if(service.category!.campaignDiscount != null){
      ///category based campaign discount
      _serviceDiscount = service.category!.campaignDiscount!.isNotEmpty ?  service.category!.campaignDiscount!.elementAt(0).discount!.discountAmount!.toDouble(): 0.0;
      _discountType = service.category!.campaignDiscount!.isNotEmpty ?  service.category!.campaignDiscount!.elementAt(0).discount!.discountAmountType! :'amount';
    }else if(service.serviceDiscount != null){
      ///service based service discount
      _serviceDiscount = service.serviceDiscount!.isNotEmpty ?  service.serviceDiscount!.elementAt(0).discount!.discountAmount!.toDouble(): 0.0;
      _discountType = service.serviceDiscount!.isNotEmpty ?  service.serviceDiscount!.elementAt(0).discount!.discountType!:'amount';
    } else{
      ///category based category discount
      _serviceDiscount = service.category!.categoryDiscount!.isNotEmpty ?  service.category!.categoryDiscount!.elementAt(0).discount!.discountAmount!.toDouble(): 0.0;
      _discountType = service.category!.categoryDiscount!.isNotEmpty ?  service.category!.categoryDiscount!.elementAt(0).discount!.discountAmountType! :'amount';
    }
    update();
  }
}