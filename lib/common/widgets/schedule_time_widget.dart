import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleTimeWidget extends StatelessWidget {
  final String title;
  final bool isReschedule;
  final BookingDetailsContent? bookingDetailsContent;
  final BookingDetailsController? bookingDetailsController;
  final bool onlyTime;
  const ScheduleTimeWidget({super.key, required this.title, this.isReschedule = false, this.bookingDetailsContent, this.bookingDetailsController, this.onlyTime = false});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ScheduleController>(builder: (scheduleController){
      return CustomExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
        children: [
          rescheduleWidget(scheduleController),
        ],
      );
    },);

  }

  // Widget rescheduleWidget(ScheduleController scheduleController){
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.withValues(alpha: 0.2),
  //               blurRadius: 8,
  //               offset: const Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         child: ListView.builder(
  //           itemCount: AppConstants.timeSlots.length,
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemBuilder: (context, index) {
  //
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 6.0),
  //               child: timeSlotItem(AppConstants.timeSlots[index], index, scheduleController),
  //             );
  //           },
  //         ),
  //       ),
  //       if(isReschedule)
  //         const SizedBox(height: 10,),
  //       if(isReschedule)
  //         CustomButton(
  //           isLoading: bookingDetailsController?.isLoading ?? false,
  //           margin: const EdgeInsets.symmetric(horizontal: 20),
  //           buttonText: 'Update',
  //           onPressed: () async{
  //
  //             String scheduledDate = bookingDetailsContent?.serviceSchedule?.split(' ').first ?? scheduleController.selectedDate;
  //             String time = AppConstants.timeSlots[scheduleController.selectedIndex].split('-').first;
  //             String formatedTime = convertTo24HourFormat(time);
  //             await bookingDetailsController?.reschedule(bookingId: bookingDetailsContent?.readableId ?? '', rescheduleTime: "$scheduledDate $formatedTime");
  //           },
  //         )
  //     ],
  //   );
  // }

  Widget rescheduleWidget(ScheduleController scheduleController) {
    // Calculate availableTimeSlots only once
    List<String> availableTimeSlots = [];
    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime.parse(scheduleController.selectedDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    bool isToday = DateFormat('yyyy-MM-dd').format(now) == DateFormat('yyyy-MM-dd').format(selectedDate);

    for (String time in AppConstants.timeSlots) {
      String startTimeStr = time.split('-').first.trim(); // e.g., '7:00 AM'
      DateTime slotTime = DateFormat('h:mm a').parse(startTimeStr);

      DateTime fullSlotTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        slotTime.hour,
        slotTime.minute,
      );

      if (!isToday || fullSlotTime.isAfter(now)) {
        availableTimeSlots.add(time);
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: availableTimeSlots.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: timeSlotItem(availableTimeSlots[index], index, scheduleController,),
              );
            },
          ),
        ),
        if (isReschedule) const SizedBox(height: 10),
        if (isReschedule)
          CustomButton(
            isLoading: bookingDetailsController?.isLoading ?? false,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            buttonText: 'Update',
            onPressed: () async {
             if(scheduleController.selectedDate == null){
               customSnackBar("Please select a date before selecting time".tr, type: ToasterMessageType.info);
               return;
             }

             print('scheduleController.selectedDate =  ${scheduleController.selectedDate}');

              String? scheduledDate = scheduleController.selectedDate ?? bookingDetailsContent?.serviceSchedule?.split(' ').first ?? scheduleController.selectedDate;
              String time = availableTimeSlots[scheduleController.selectedIndex].split('-').first;
              String formattedTime = convertTo24HourFormat(time);
              await bookingDetailsController?.reschedule(
                bookingId: bookingDetailsContent?.readableId ?? '',
                rescheduleTime: "$scheduledDate $formattedTime",
              );
            },
          )
      ],
    );
  }

  Widget timeSlotItem(String timeRange, int index, ScheduleController scheduleController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheduleController.selectedIndex == index ? Colors.grey : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: InkWell(
        onTap: () {
          if(scheduleController.selectedDate == null){
            customSnackBar("Please select a date before selecting time".tr, type: ToasterMessageType.info);
            return;
          }
          scheduleController.updateIndex(index);
          ConfigModel config = Get.find<SplashController>().configModel;
          String selectedTime = timeRange.split('-').first;
          String convertedTime = convertTo24HourFormat(selectedTime);
          scheduleController.selectedTime = convertedTime;
          if(onlyTime){
            scheduleController.selectedTime = convertedTime;
          }
          if(!isReschedule){
            scheduleController.selectedTime = convertedTime;
            String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
            String fullScheduleTime = '${scheduleController.selectedDate} $convertedTime';
            scheduleController.updateSelectedDate(fullScheduleTime);
            scheduleController.updateScheduleType(scheduleType: ScheduleType.schedule, shouldUpdate: true);

            if(scheduleController.initialSelectedScheduleType == null){
              customSnackBar('select_your_preferable_booking_time'.tr, showDefaultSnackBar: false);
            }
            else if(config.content!.advanceBooking != null && config.content?.scheduleBookingTimeRestriction == 1 && scheduleController.initialSelectedScheduleType != ScheduleType.asap){

              if(scheduleController.checkValidityOfTimeRestriction(config.content!.advanceBooking!) !=null){
                customSnackBar(scheduleController.checkValidityOfTimeRestriction(config.content!.advanceBooking!), showDefaultSnackBar: false);
              }else{
                scheduleController.buildSchedule(scheduleType: ScheduleType.schedule, schedule: fullScheduleTime);
              }
            }else{
              scheduleController.buildSchedule(scheduleType: ScheduleType.schedule, schedule: fullScheduleTime);
            }
          }else{
            ///reschedule
          }
        },
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: scheduleController.selectedIndex == index ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String convertTo24HourFormat(String time) {
    // Step 1: Parse the original 12-hour time
    final inputFormat = DateFormat('h:mm a');
    final dateTime = inputFormat.parse(time);

    // Step 2: Format to 24-hour with seconds
    final outputFormat = DateFormat('HH:mm:ss');
    return outputFormat.format(dateTime);
  }

}
