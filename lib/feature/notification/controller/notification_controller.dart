import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class NotificationController extends GetxController implements GetxService{
  bool _isLoading = false;

  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});


  NotificationModel? _notificationModel;
  NotificationModel? get notificationModel => _notificationModel;
  List<String> dateList = [];
  List allNotificationList=[];
  List<dynamic> notificationList=[];
  bool get isLoading => _isLoading;
  int _offset = 1;
  int get offset => _offset;
  final ScrollController scrollController = ScrollController();



  Future<void> getNotifications(int offset, {bool reload = true})async{
    _offset = offset;


    _isLoading = true;
    try {
      Response response = await notificationRepo.getNotificationList(offset);
      if(response.statusCode == 200 && response.body is Map){
        if(reload){
          allNotificationList = [];
          notificationList = [];
          dateList = [];
        }else{
          allNotificationList =[];
        }
        try {
          _notificationModel = NotificationModel.fromJson(Map<String, dynamic>.from(response.body));
        } catch (_) {
          _notificationModel = null;
        }

        final notifications = _notificationModel?.content?.data ?? [];

        for (var data in notifications) {
          final day = _dayLabel(data.createdAt);
          if(day != null && !dateList.contains(day)) {
            dateList.add(day);
          }
        }

        allNotificationList.addAll(notifications);

        for(int i=0; i< dateList.length;i++){
          notificationList.add([]);
          for (var element in allNotificationList) {
            if(dateList[i] == _dayLabel(element.createdAt)){
              notificationList[i].add(element);
            }
          }
        }
      } else{
        ApiChecker.checkApi(response);
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      update();
    }
  }

  String? _dayLabel(String? createdAt) {
    final date = DateTime.tryParse(createdAt ?? '');
    if (date == null) {
      return null;
    }
    return DateConverter.dateStringMonthYear(date);
  }
}
