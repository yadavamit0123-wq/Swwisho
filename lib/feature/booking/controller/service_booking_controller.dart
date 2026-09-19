import 'dart:convert';

import 'package:demandium/common/models/popup_menu_model.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/booking/model/service_availability_model.dart';
import 'package:demandium/feature/booking/widget/provider_available_bottom_sheet.dart';
import 'package:demandium/feature/booking/widget/service_unavailable_dialog.dart';
import 'package:get/get.dart';

enum BookingStatusTabs {all, pending, accepted, ongoing,completed,canceled }

class ServiceBookingController extends GetxController implements GetxService {
  final ServiceBookingRepo serviceBookingRepo;

  ServiceBookingController({required this.serviceBookingRepo});

  List<BookingModel>? _bookingList;

  List<BookingModel>? get bookingList => _bookingList;
  int _offset = 1;

  int? get offset => _offset;
  BookingContent? _bookingContent;

  BookingContent? get bookingContent => _bookingContent;

  int _bookingListPageSize = 0;
  final int _bookingListCurrentPage = 0;

  int get bookingListPageSize => _bookingListPageSize;

  int get bookingListCurrentPage => _bookingListCurrentPage;
  BookingStatusTabs _selectedBookingStatus = BookingStatusTabs.all;

  BookingStatusTabs get selectedBookingStatus => _selectedBookingStatus;

  bool _isNotAvailable = false;
  bool get isNotAvailable => _isNotAvailable;

  bool _isPriceChanged = false;
  bool get isPriceChanged => _isPriceChanged;

  ServiceAvailabilityModel? serviceAvailability;

  int _rebookIndex=-1;
  int get  selectedRebookIndex => _rebookIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ServiceType selectedServiceType = ServiceType.all;


  void updateBookingStatusTabs(BookingStatusTabs bookingStatusTabs,
      {bool firstTimeCall = true, bool fromMenu = false}) {
    _selectedBookingStatus = bookingStatusTabs;
    if (firstTimeCall) {
      getAllBookingService(offset: 1, bookingStatus: _selectedBookingStatus.name.toLowerCase(), isFromPagination: false,
        serviceType: selectedServiceType.name
      );
    }
  }


  Future<void> getAllBookingService({required int offset, required String bookingStatus, required bool isFromPagination, bool fromMenu = false, required String serviceType}) async {
    _offset = offset;
    if (!isFromPagination) {
      _bookingList = null;
    }
    try {
      Response response = await serviceBookingRepo.getBookingList(offset: offset, bookingStatus: bookingStatus, serviceType: serviceType);
      if (response.statusCode == 200 && response.body is Map) {
        ServiceBookingList serviceBookingModel = ServiceBookingList.fromJson(
            Map<String, dynamic>.from(response.body));
        if (!isFromPagination) {
          _bookingList = [];
        }
        _bookingList ??= [];
        _bookingList!.addAll(serviceBookingModel.content?.bookingModel ?? []);
        _bookingListPageSize = int.tryParse(
          (response.body['content'] is Map ? response.body['content']['last_page'] : null)?.toString() ?? '',
        ) ?? 1;
        _bookingContent = serviceBookingModel.content;
      } else {
        _bookingList ??= [];
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _bookingList ??= [];
    }
    update();
  }


  BuildContext? get _overlayContext => Get.overlayContext ?? Get.context;

  bool _isSuccessfulResponse(Response response) {
    if (response.statusCode != 200) return false;
    if (response.body is! Map) return true;
    final code = response.body['response_code']?.toString();
    if (code == null || code.isEmpty) return true;
    return code.contains('200');
  }

  bool _isAuthFailure(Response response) {
    return response.statusCode == 401;
  }

  String? _responseMessage(Response response) {
    if (response.body is Map && response.body['message'] != null) {
      return response.body['message'].toString();
    }
    if (response.statusText != null && response.statusText!.isNotEmpty) {
      return response.statusText;
    }
    return null;
  }

  void _showApiFailure(Response response) {
    if (response.statusCode == 1) {
      customSnackBar(
        response.statusText ?? 'connection_to_api_server_failed'.tr,
        type: ToasterMessageType.error,
      );
      return;
    }
    final message = _responseMessage(response);
    if (message != null && message.isNotEmpty) {
      customSnackBar(message, type: ToasterMessageType.error);
      return;
    }
    try {
      ApiChecker.checkApi(response);
    } catch (_) {
      customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    }
  }

  void _closeLoaderDialog(bool loaderOpen) {
    if (!loaderOpen) return;
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (_) {}
  }

  void _showRebookOverlay(Widget child) {
    final context = _overlayContext;
    if (context == null) {
      customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      return;
    }
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Center(child: child));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => child,
    );
  }

  Future<void> _closeRebookOverlayIfNeeded(bool isBack) async {
    if (!isBack) return;
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      } else if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (_) {}
  }

  Future<bool> _rebookViaCart(String bookingId) async {
    Response detailsResponse = await serviceBookingRepo.getBookingDetails(bookingID: bookingId);
    if (detailsResponse.statusCode != 200 || detailsResponse.body is! Map) {
      return false;
    }

    BookingDetailsContent? content;
    try {
      content = BookingDetailsModel.fromJson(
        Map<String, dynamic>.from(detailsResponse.body),
      ).content;
    } catch (_) {}

    final items = content?.bookingDetails ?? [];
    if (content == null || items.isEmpty) {
      return false;
    }

    int added = 0;
    for (final item in items) {
      final serviceId = item.serviceId ?? item.service?.id;
      if (serviceId == null || serviceId.isEmpty) {
        continue;
      }

      final cartBody = CartModelBody(
        serviceId: serviceId,
        categoryId: content.categoryId ?? item.service?.categoryId,
        variantKey: item.variantKey,
        quantity: (item.quantity ?? 1).toString(),
        subCategoryId: content.subCategoryId ?? item.service?.subCategoryId,
        providerId: content.providerId,
        guestId: Get.find<SplashController>().getGuestId(),
      );

      try {
        Response addResponse = await Get.find<CartRepo>().addToCartListToServer(cartBody);
        if (addResponse.statusCode != 200 && cartBody.providerId != null) {
          cartBody.providerId = null;
          addResponse = await Get.find<CartRepo>().addToCartListToServer(cartBody);
        }
        if (addResponse.statusCode == 200) {
          added++;
        }
      } catch (_) {}
    }

    if (added == 0) {
      return false;
    }

    try {
      await Get.find<CartController>().getCartListFromServer(shouldUpdate: true);
    } catch (_) {}
    return true;
  }

  Future<void> rebook(String bookingId, {bool isBack = false}) async {
    _isLoading = true;
    update();
    try {
      Response response = await serviceBookingRepo.addRebookToServer(bookingId);
      if (_isSuccessfulResponse(response)) {
        await _closeRebookOverlayIfNeeded(isBack);
        try {
          await Get.find<CartController>().getCartListFromServer(shouldUpdate: true);
        } catch (_) {}
        customSnackBar(
          _responseMessage(response) ?? 'success'.tr,
          type: ToasterMessageType.success,
        );
      } else if (_isAuthFailure(response)) {
        _showApiFailure(response);
      } else {
        final added = await _rebookViaCart(bookingId);
        if (added) {
          await _closeRebookOverlayIfNeeded(isBack);
          customSnackBar('successfully_added_to_cart'.tr, type: ToasterMessageType.success);
        } else {
          customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
        }
      }
    } catch (_) {
      customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      _isLoading = false;
      update();
    }
  }


  Future<void> checkRebookAvailability(String bookingId) async {
    _isPriceChanged = false;
    _isNotAvailable = false;
    _isLoading = true;
    update();

    bool loaderOpen = false;
    try {
      try {
        Get.dialog(const CustomLoader(), barrierDismissible: false);
        loaderOpen = true;
      } catch (_) {}

      Response response = await serviceBookingRepo.rebookCheck(bookingId);
      _closeLoaderDialog(loaderOpen);
      loaderOpen = false;

      if (!_isSuccessfulResponse(response)) {
        if (_isAuthFailure(response)) {
          _showApiFailure(response);
        } else {
          await rebook(bookingId);
        }
        return;
      }

      Map<String, dynamic> jsonBody = {};
      final dynamic body = response.body;
      try {
        if (body is Map) {
          jsonBody = Map<String, dynamic>.from(body);
        } else if (body is String && body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map) {
            jsonBody = Map<String, dynamic>.from(decoded);
          }
        }
      } catch (_) {}

      try {
        serviceAvailability = ServiceAvailabilityModel.fromJson(jsonBody);
      } catch (_) {
        serviceAvailability = null;
      }

      final services = serviceAvailability?.content?.services ?? [];
      for (final service in services) {
        if (service.isPriceChanged == 1) {
          _isPriceChanged = true;
        }
        if (service.isAvailable == 0) {
          _isNotAvailable = true;
        }
      }
      update();

      final isProviderAvailable = serviceAvailability?.content?.isProviderAvailable;

      if (isProviderAvailable == 0) {
        _showRebookOverlay(RebookWarningBottomSheet(bookingId: bookingId));
      } else if (_isNotAvailable || _isPriceChanged) {
        _showRebookOverlay(ServiceUnavailableDialog(
          bookingId: bookingId,
          isPriceChanged: _isPriceChanged,
          isNotAvailable: _isNotAvailable,
          isAllNotAvailable: checkAllServiceAvailable(services),
        ));
      } else {
        await rebook(bookingId);
      }
    } catch (_) {
      customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      _closeLoaderDialog(loaderOpen);
      _isLoading = false;
      update();
    }
  }


  Future<void> checkCartSubcategory(String bookingId, String subcategoryId) async {
    try {
      if (subcategoryId.isNotEmpty && Get.find<CartController>().cartList.isNotEmpty) {
        final cartList = Get.find<CartController>().cartList;
        if (cartList[0].subCategoryId != subcategoryId) {
          Get.dialog(ConfirmationDialog(
            icon: Images.warning,
            title: "are_you_sure_to_reset".tr,
            description: 'you_have_service_from_other_sub_category'.tr,
            onYesPressed: () async {
              Get.back();
              await Get.find<CartController>().removeAllCartItem();
              await checkRebookAvailability(bookingId);
            },
          ));
          return;
        }
      }
      await checkRebookAvailability(bookingId);
    } catch (_) {
      customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    }
  }

  void updateRebookIndex (int index) {
    _rebookIndex = index;
    update();
  }


  bool checkAllServiceAvailable (List<Services>? services) {
    bool available = true;
    for (final service in services ?? <Services>[]) {
      if(available && service.isAvailable == 1) {
        available = false;
      }
    }
    return available;
  }

  void updateSelectedServiceType({ServiceType? type}){
    if(type!=null){
      selectedServiceType = type;
      update();
      getAllBookingService(offset: 1, bookingStatus: _selectedBookingStatus.name, isFromPagination: false, serviceType: type.name);
    }else{
      selectedServiceType = ServiceType.all;
    }
  }

  List<PopupMenuModel> getPopupMenuList({required String status, bool isRepeatBooking = false, RepeatBooking? ongoingRepeatBooking }) {
    if (status == "pending") {
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        // PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),
      ];
    } else if (status == "accepted" || status == "ongoing") {
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        if(status == "accepted") PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),

      ];
    }
    else if (status == "canceled"|| status == "completed") {
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        if(!isRepeatBooking)  PopupMenuModel(title: "rebook", icon: Icons.repeat),
      ];
    }
    return [];
  }

}
