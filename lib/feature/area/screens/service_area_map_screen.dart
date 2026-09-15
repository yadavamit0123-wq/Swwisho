import 'package:demandium/feature/area/widget/area_map_view.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ServiceAreaMapScreen extends StatefulWidget {
  const ServiceAreaMapScreen({super.key}) ;

  @override
  State<ServiceAreaMapScreen> createState() => _ServiceAreaMapScreenState();
}

class _ServiceAreaMapScreenState extends State<ServiceAreaMapScreen> {
  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      await HomeScreen.ensureZoneHeader();
      await Get.find<ServiceAreaController>().getZoneList(reload: false);
    } catch (_) {
      try {
        await Get.find<ServiceAreaController>().getZoneList(reload: false);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(centerTitle: false, title: 'our_services_areas'.tr, showCart: false),
      body: GetBuilder<ServiceAreaController>(builder: (serviceAreaController){
        if (serviceAreaController.zoneList == null) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final zones = serviceAreaController.zoneList ?? [];
        if (zones.isEmpty) {
          return Center(
            child: NoDataScreen(
              text: 'no_data_found'.tr,
              type: NoDataType.others,
            ),
          );
        }

        return Column(
          children: [
            Expanded(child: AreaMapViewScreen(zoneList: zones)),
          ],
        );
      }),
    );
  }
}
