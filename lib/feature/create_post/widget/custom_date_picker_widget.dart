import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/create_post/widget/custom_date_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomDateTimePickerWidget extends StatefulWidget {
  final String? title;
  const CustomDateTimePickerWidget({super.key, this.title});

  @override
  State<CustomDateTimePickerWidget> createState() => _CustomDateTimePickerWidgetState();
}

class _CustomDateTimePickerWidgetState extends State<CustomDateTimePickerWidget> {
  final DateRangePickerController dateRangePickerController = DateRangePickerController();

  @override
  void dispose() {
    dateRangePickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(builder: (scheduleController) {
      Get.find<ScheduleController>().setInitialScheduleValue();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(widget.title ?? 'Select Date',style: robotoMedium,),
          const SizedBox(height: 16,),
          Container(
            width: ResponsiveHelper.isDesktop(context) ? Dimensions.webMaxWidth / 2 : Dimensions.webMaxWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: 4,
                  width: 80,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                CustomDatePicker(dateRangePickerController: dateRangePickerController, onClickDate: onClickDate),
              ],
            ),
          ),
        ],
      );
    });
  }

  onClickDate(BuildContext context, ScheduleController scheduleController){
    ConfigModel config = Get.find<SplashController>().configModel;
    if (scheduleController.initialSelectedScheduleType == null) {
      customSnackBar('select_your_preferable_booking_time'.tr, showDefaultSnackBar: false);
    } else if (config.content?.advanceBooking != null && config.content?.scheduleBookingTimeRestriction == 1 && scheduleController.initialSelectedScheduleType != ScheduleType.asap) {
      if (scheduleController.checkValidityOfTimeRestriction(config.content!.advanceBooking!) != null) {
        customSnackBar(scheduleController.checkValidityOfTimeRestriction(config.content!.advanceBooking!), showDefaultSnackBar: false);
      } else {
        // scheduleController.buildSchedule(scheduleType: ScheduleType.schedule);
      }
    } else {
      // scheduleController.buildSchedule(scheduleType: scheduleController.selectedScheduleType);
    }
  }
}