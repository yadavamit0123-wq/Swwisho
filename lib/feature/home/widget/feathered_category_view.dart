import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class FeatheredCategoryView extends StatefulWidget {
  const FeatheredCategoryView({super.key}) ;

  @override
  State<FeatheredCategoryView> createState() => _FeatheredCategoryViewState();
}

class _FeatheredCategoryViewState extends State<FeatheredCategoryView> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController){

      final categories = serviceController.categoryList;
      if (categories == null || categories.isEmpty) {
        return const SizedBox();
      }

      return SizedBox(
        height: categories.length * 330,
        child: ListView.builder(itemBuilder: (context,categoryIndex){

          final services = categories[categoryIndex].servicesByCategory ?? [];
          if (services.isEmpty) {
            return const SizedBox();
          }
          final serviceItemCount = services.length > 5 ? 5 : services.length;

          return  Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ),
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall,horizontal: 0),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeExtraSmall,
                  ),
                  child: TitleWidget(
                    textDecoration: TextDecoration.underline,
                    title: categories[categoryIndex].name??"",
                    onTap: () =>  Get.toNamed(RouteHelper.getFeatheredCategoryService(
                        categories[categoryIndex].name??"", categories[categoryIndex].id ?? ""),
                    ),
                  ),
                ),

                SizedBox(
                  height: 255,
                  width: Get.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault,bottom: Dimensions.paddingSizeExtraSmall,top: Dimensions.paddingSizeExtraSmall),
                    itemCount: serviceItemCount,
                    itemBuilder: (context, index) {
                      return Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall + 2),
                        child: SizedBox(
                           width: ResponsiveHelper.isTab(context) ? 250 : Get.width / 2.30,
                            child: ServiceWidgetVertical(service: services[index],
                          fromType: '',
                        )
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall)
              ],
            ),
          );
        },itemCount: serviceController.categoryList?.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
        ),
      );
    });
  }
}
