import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/area/widget/area_top_widget.dart';
import 'package:demandium/feature/area/widget/area_view_widget.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      await Get.find<ServiceAreaController>().getZoneList(reload: true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('our_services_areas'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadZones,
        child: FooterBaseView(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: const Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  AreaTopWidget(),
                  AreaViewWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
