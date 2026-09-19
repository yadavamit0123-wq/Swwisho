import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/review/repo/submit_review_repo.dart';

class SubmitReviewController extends GetxController {
  final SubmitReviewRepo submitReviewRepo ;
  SubmitReviewController({required this.submitReviewRepo});


  bool _isLoading = false;
  get isLoading => _isLoading;

  bool _loading = false;
  get loading => _loading;

  List<Service>? _serviceReviewList;
  List<Service>? get serviceReviewList => _serviceReviewList;

  Map<String,Map<String, dynamic>> listOfReview = {};

  TextEditingController reviewController = TextEditingController();
  Map<String, TextEditingController> textControllers =  {};
  Map<String, int> selectedRating =  {};
  Map<String, bool> isEditable =  {};
  Map<String, String> reviewComments =  {};

  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;

   selectReview(int rating,serviceId){
     selectedRating[serviceId] = rating;
    update();
  }

  void setIndex(int index){
    _selectedIndex= index;
    update();
  }

  Future<void> submitReview(ReviewBody reviewBody,String serviceId,String review, int index)async{
    _isLoading = true;
    update();
    Response response =await submitReviewRepo.submitReview(reviewBody: reviewBody);
    if(response.statusCode == 200){
      isEditable[serviceId] = false;
      reviewComments[serviceId]= review;
      customSnackBar('review_submitted_successfully'.tr,type : ToasterMessageType.success);
    }
    _isLoading = false;
    update();
  }


  Future<void> getReviewList(String bookingId, {BookingDetailsContent? bookingDetails}) async {
    _loading = true;
    update();

    try {
      Response response = await submitReviewRepo.getReviewList(bookingId: bookingId);
      if (response.statusCode == 200 && response.body is Map) {
        final content = response.body['content'];
        if (content is List && content.isNotEmpty) {
          _serviceReviewList = [];
          for (final element in content) {
            try {
              if (element is Map) {
                _serviceReviewList!.add(Service.fromJson(Map<String, dynamic>.from(element)));
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    if (_serviceReviewList == null || _serviceReviewList!.isEmpty) {
      _populateFromBookingDetails(bookingDetails);
    } else {
      _initializeReviewFields();
    }

    _loading = false;
    update();
  }

  void _populateFromBookingDetails(BookingDetailsContent? bookingDetails) {
    _serviceReviewList = [];
    for (final item in bookingDetails?.bookingDetails ?? <ItemService>[]) {
      if (item.service != null) {
        _serviceReviewList!.add(item.service!);
      } else if (item.serviceId != null && item.serviceId!.isNotEmpty) {
        _serviceReviewList!.add(Service(id: item.serviceId, name: item.serviceName));
      }
    }
    _initializeReviewFields();
  }

  void _initializeReviewFields() {
    for (final element in _serviceReviewList ?? <Service>[]) {
      final serviceId = element.id;
      if (serviceId == null || serviceId.isEmpty) {
        continue;
      }

      textControllers[serviceId] = TextEditingController();

      if (element.review != null && element.review!.isNotEmpty) {
        selectedRating[serviceId] = element.review!.first.reviewRating ?? 5;
        isEditable[serviceId] = element.review!.isEmpty;
        reviewComments[serviceId] = element.review!.first.reviewComment ?? "";
        textControllers[serviceId]!.text = element.review!.first.reviewComment ?? "";
      } else {
        selectedRating[serviceId] = 5;
        isEditable[serviceId] = true;
        reviewComments[serviceId] = "";
        textControllers[serviceId]!.text = "";
      }
    }
  }

  void updateEditableValue(String serviceId,bool value,{bool isUpdate= false}){
    isEditable[serviceId] = value;
    if(isUpdate){
      update();
    }
  }
}