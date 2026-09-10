import 'package:demandium/common/models/popup_menu_model.dart';
import 'package:demandium/feature/checkout/widget/payment_section/incomplete_offline_payment_dialog.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class BookingDetailsController extends GetxController implements GetxService {
  final BookingDetailsRepo bookingDetailsRepo;

  BookingDetailsController({required this.bookingDetailsRepo});

  BookingDetailsContent? _bookingDetailsContent;
  BookingDetailsContent? _subBookingDetailsContent;
  DigitalPaymentMethod? _selectedDigitalPaymentMethod;

  bool _isLoading = false;

  BookingDetailsContent? get bookingDetailsContent => _bookingDetailsContent;
  BookingDetailsContent? get subBookingDetailsContent => _subBookingDetailsContent;
  DigitalPaymentMethod? get selectedDigitalPaymentMethod => _selectedDigitalPaymentMethod;
  bool get isLoading => _isLoading;

  Future<void> getBookingDetails({required String bookingId, bool reload = true}) async {
    if (reload) {
      _isLoading = true;
      update();
    }
    Response response = await bookingDetailsRepo.getBookingDetails(bookingID: bookingId);
    if (response.statusCode == 200) {
      _bookingDetailsContent = BookingDetailsModel.fromJson(response.body).content;
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getSubBookingDetails({required String bookingId, bool reload = true}) async {
    if (reload) {
      _isLoading = true;
      update();
    }
    Response response = await bookingDetailsRepo.getSubBookingDetails(bookingID: bookingId);
    if (response.statusCode == 200) {
      _subBookingDetailsContent = BookingDetailsModel.fromJson(response.body).content;
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> trackBookingDetails(String bookingId, String phoneNumber, {bool reload = true}) async {
    if (reload) {
      _isLoading = true;
      update();
    }
    Response response = await bookingDetailsRepo.trackBookingDetails(
      bookingID: bookingId,
      phoneNUmber: phoneNumber,
    );
    if (response.statusCode == 200) {
      _bookingDetailsContent = BookingDetailsModel.fromJson(response.body).content;
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> bookingCancel({required String bookingId}) async {
    _isLoading = true;
    update();
    Response response = await bookingDetailsRepo.bookingCancel(bookingID: bookingId);
    if (response.statusCode == 200) {
      await getBookingDetails(bookingId: bookingId, reload: false);
      customSnackBar(response.body['message'], type: ToasterMessageType.success);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> subBookingCancel({required String subBookingId}) async {
    _isLoading = true;
    update();
    Response response = await bookingDetailsRepo.subBookingCancel(bookingID: subBookingId);
    if (response.statusCode == 200) {
      await getSubBookingDetails(bookingId: subBookingId, reload: false);
      customSnackBar(response.body['message'], type: ToasterMessageType.success);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> reschedule({required String bookingId, required String rescheduleTime}) async {
    _isLoading = true;
    update();
    Response response = await bookingDetailsRepo.reschedule(
      bookingId: bookingId,
      rescheduleTime: rescheduleTime,
    );
    if (response.statusCode == 200) {
      customSnackBar(response.body['message'], type: ToasterMessageType.success);
      await getBookingDetails(bookingId: bookingId, reload: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void updateSelectedDigitalPayment({DigitalPaymentMethod? value, bool shouldUpdate = true}) {
    _selectedDigitalPaymentMethod = value;
    if (shouldUpdate) {
      update();
    }
  }

  void resetBookingDetailsValue({bool resetBookingDetails = false, bool resetSubBookingDetails = false}) {
    if (resetBookingDetails) {
      _bookingDetailsContent = null;
    }
    if (resetSubBookingDetails) {
      _subBookingDetailsContent = null;
    }
    update();
  }

  Future<void> manageDialog() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      BookingDetailsContent? booking = Get.find<UserController>().userInfoModel?.lastIncompleteOfflineBooking;
      if (booking != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.context != null) {
            Get.dialog(IncompleteOfflinePaymentDialog(booking: booking));
          }
        });
      }
    }
  }

  List<PopupMenuModel> getPopupMenuList(String status) {
    if (status == 'pending') {
      return [
        PopupMenuModel(title: 'download_invoice', icon: Icons.file_download_outlined),
        PopupMenuModel(title: 'cancel', icon: Icons.cancel_outlined),
      ];
    } else if (status == 'accepted' || status == 'ongoing') {
      return [
        PopupMenuModel(title: 'download_invoice', icon: Icons.file_download_outlined),
        if (status == 'accepted') PopupMenuModel(title: 'cancel', icon: Icons.cancel_outlined),
      ];
    } else if (status == 'canceled' || status == 'completed') {
      return [
        PopupMenuModel(title: 'download_invoice', icon: Icons.file_download_outlined),
      ];
    }
    return [];
  }

  List<PopupMenuModel> getPServiceLogMenuList({required String status, bool nextService = false}) {
    if (status == 'pending' || status == 'accepted' || status == 'ongoing') {
      return [
        PopupMenuModel(title: 'booking_details', icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: 'download_invoice', icon: Icons.file_download_outlined),
        if (!nextService) PopupMenuModel(title: 'cancel', icon: Icons.cancel_outlined),
      ];
    }
    return [
      PopupMenuModel(title: 'booking_details', icon: Icons.remove_red_eye_sharp),
      PopupMenuModel(title: 'download_invoice', icon: Icons.file_download_outlined),
    ];
  }
}
