import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String? serviceID;
  final String? fromPage;
  const ServiceDetailsScreen({super.key, this.serviceID,this.fromPage="others"}) ;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {

  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      await HomeScreen.ensureZoneHeader();
    } catch (_) {}
    try {
      if (!Get.isRegistered<ServiceTabController>()) {
        Get.put(ServiceTabController(serviceDetailsRepo: Get.find()));
      }
    } catch (_) {}
    final serviceId = widget.serviceID;
    if (serviceId != null && serviceId.isNotEmpty) {
      Get.find<ServiceDetailsController>().getServiceDetails(
        serviceId,
        fromPage: widget.fromPage == "search_page" ? "search_page" : "",
      );
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<ServiceController>().getRecentlyViewedServiceList(1, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(centerTitle: false, title: 'service_details'.tr,showCart: true,),
      body: GetBuilder<ServiceDetailsController>(
        builder: (serviceController) {
          if(serviceController.service != null || widget.serviceID == null){
            if(serviceController.service != null && serviceController.service!.id != null &&  widget.serviceID != null){
              Service service = serviceController.service!;
              Discount discount;
              try {
                discount = PriceConverter.discountCalculation(service);
              } catch (_) {
                discount = Discount(discountAmount: 0.0, discountAmountType: 'amount');
              }
              double lowestPrice = 0.0;
              final zoneWiseVariations = service.variationsAppFormat?.zoneWiseVariations ?? [];
              for (final variation in zoneWiseVariations) {
                final price = (variation.price ?? 0).toDouble();
                if (lowestPrice == 0.0 || price < lowestPrice) {
                  lowestPrice = price;
                }
              }
              return  FooterBaseView(
                isScrollView: ResponsiveHelper.isMobile(context) ? false: true,
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: DefaultTabController(
                    length: (service.faqs?.isNotEmpty ?? false) ? 3 :2,
                    child: Column(
                      children: [
                        if(!ResponsiveHelper.isMobile(context) && !ResponsiveHelper.isTab(context))
                        const SizedBox(height: Dimensions.paddingSizeDefault,),
                        Stack(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all((!ResponsiveHelper.isMobile(context) && !ResponsiveHelper.isTab(context)) ?  const Radius.circular(8): const Radius.circular(0.0)),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          height: ResponsiveHelper.isDesktop(context) ? 280:150,
                                          child: CustomImage(image: service.coverImageFullPath ?? ""),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: Dimensions.webMaxWidth,
                                          height: ResponsiveHelper.isDesktop(context) ? 280:150,
                                          decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.6)
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: Dimensions.webMaxWidth,
                                        height: ResponsiveHelper.isDesktop(context) ? 280:150,
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                        child: Center(child: Text(service.name ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white))),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 120,)
                              ],
                            ),
                            Positioned(
                              bottom: -2, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                              child: ServiceInformationCard(discount: discount,service: service,lowestPrice: lowestPrice,),
                            ),
                          ],
                        ),
                        //Tab Bar
                        GetBuilder<ServiceTabController>(
                          builder: (serviceTabController) {
                            return Container(
                              color:Theme.of(context).scaffoldBackgroundColor,
                              child: Center(
                                child: Container(
                                  width: ResponsiveHelper.isMobile(context) ?null : Get.width / 3,
                                  color: Get.isDarkMode?Theme.of(context).scaffoldBackgroundColor:Theme.of(context).cardColor,
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: DecoratedTabBar(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: .3),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    tabBar: TabBar(
                                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeMini),
                                        unselectedLabelColor: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: 0.4),
                                        labelColor:Get.isDarkMode? Colors.white : Theme.of(context).primaryColor,
                                        labelStyle: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                        indicatorColor: Theme.of(context).colorScheme.primary,
                                        indicatorPadding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                        labelPadding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                                        indicatorWeight: 2,
                                        onTap: (int? index) {
                                          switch (index) {
                                            case 0:
                                              serviceTabController.updateServicePageCurrentState(ServiceTabControllerState.serviceOverview);
                                              break;
                                            case 1:
                                              serviceTabController.serviceDetailsTabs().length > 2 ?
                                              serviceTabController.updateServicePageCurrentState(ServiceTabControllerState.faq):
                                              serviceTabController.updateServicePageCurrentState(ServiceTabControllerState.review);
                                              break;
                                            case 2:
                                              serviceTabController.updateServicePageCurrentState(ServiceTabControllerState.review);
                                              break;
                                          }
                                        },
                                        tabs: serviceTabController.serviceDetailsTabs()
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        //Tab Bar View
                        GetBuilder<ServiceTabController>(
                          initState: (state){
                            try {
                              Get.find<ServiceTabController>().getServiceReview(service.id ?? '', 1);
                            } catch (_) {}
                          },
                          builder: (controller){
                            Widget tabBarView = TabBarView(
                              children: [
                                SingleChildScrollView(child: ServiceOverview(description: service.description ?? '')),
                                if(service.faqs?.isNotEmpty ?? false)
                                  const SingleChildScrollView(child: ServiceDetailsFaqSection()),
                                SingleChildScrollView(
                                  child: ServiceDetailsReview(serviceID: service.id ?? '',),
                                ),
                              ],
                            );

                            if(ResponsiveHelper.isMobile(context)){
                              return Expanded(
                                child: tabBarView,
                              );
                            }else{
                              return SizedBox(
                                height: 500,
                                child: tabBarView,);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }else{
              return NoDataScreen(text: 'no_service_available'.tr,type: NoDataType.service,);
            }
          }else{
            return const ServiceDetailsShimmerWidget();
          }

        },
      ),
    );
  }
}

