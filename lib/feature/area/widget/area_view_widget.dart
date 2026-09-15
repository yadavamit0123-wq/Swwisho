import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class AreaViewWidget extends StatelessWidget {
  const AreaViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final zoneId = Get.find<LocationController>().getUserAddress()?.zoneId;
    return GetBuilder<ServiceAreaController>(
        builder: (serviceAreaController) {
          if (serviceAreaController.zoneList == null) {
            return const AvailableAreaShimmer();
          }

          final zones = serviceAreaController.zoneList ?? [];
          if (zones.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: NoDataScreen(
                text: 'no_data_found'.tr,
                type: NoDataType.others,
              ),
            );
          }

          return GridView.builder(
            key: UniqueKey(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.7,
              mainAxisSpacing: Dimensions.paddingSizeEight,
              crossAxisSpacing: Dimensions.paddingSizeEight,
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 3,
            ),
            physics:const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              final isSelected = zoneId != null && zoneId == zone.id;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 0),
                child: Column(
                  children: [
                    isSelected ? Column( mainAxisSize: MainAxisSize.min, children: [
                      Text('your_area'.tr, style:  robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 3),
                    ]) : const SizedBox(height: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(RouteHelper.getPickMapRoute("", true, 'false', zone, Get.find<LocationController>().getUserAddress()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.45) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)),
                            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeEight),
                          child: Center(
                            child: Text(zone.name ?? '', style: robotoRegular, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }
}




class AvailableAreaShimmer extends StatelessWidget {
  const AvailableAreaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.7,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 3,
        ),
        physics:const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: ResponsiveHelper.isMobile(context) ? 10 : 15,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 0),
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).cardColor,
                      boxShadow: Get.isDarkMode?null:[BoxShadow(color: Colors.grey[200]!, blurRadius: 5, spreadRadius: 1)],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
