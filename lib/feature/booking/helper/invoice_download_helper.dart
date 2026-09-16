import 'package:demandium/feature/booking/controller/invoice_controller.dart';
import 'package:demandium/feature/booking/model/invoice.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

class InvoiceDownloadHelper {
  static Future<void> download({
    required String bookingId,
    bool isSubBooking = false,
    BookingDetailsContent? content,
  }) async {
    if (bookingId.isEmpty && content == null) {
      customSnackBar('something_went_wrong'.tr);
      return;
    }

    Get.dialog(const CustomLoader(), barrierDismissible: false);
    try {
      BookingDetailsContent? booking = content;
      final controller = Get.find<BookingDetailsController>();

      if (booking == null) {
        final repo = Get.find<BookingDetailsRepo>();
        final response = isSubBooking
            ? await repo.getSubBookingDetails(bookingID: bookingId)
            : await repo.getBookingDetails(bookingID: bookingId);
        if (response.statusCode == 200 && response.body is Map) {
          booking = BookingDetailsModel.fromJson(
            Map<String, dynamic>.from(response.body),
          ).content;
        }
      }

      if (booking == null) {
        _closeLoader();
        customSnackBar('something_went_wrong'.tr);
        return;
      }

      final items = (booking.bookingDetails ?? []).map((service) {
        return InvoiceItem(
          discountAmount: (service.discountAmount ?? 0).toStringAsFixed(2),
          tax: (service.taxAmount ?? 0).toStringAsFixed(2),
          serviceName: service.serviceName ?? service.variantKey ?? 'Service',
          quantity: service.quantity ?? 0,
          unitAllTotal: (service.totalCost ?? 0).toStringAsFixed(2),
          unitPrice: (service.serviceCost ?? 0).toStringAsFixed(2),
        );
      }).toList();

      final bytes = await InvoiceController.generateUint8List(
        booking,
        items,
        controller,
      );

      _closeLoader();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice-${booking.readableId ?? booking.id ?? bookingId}.pdf',
      );
    } catch (_) {
      _closeLoader();
      customSnackBar('something_went_wrong'.tr);
    }
  }

  static void _closeLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
