import 'package:demandium/feature/home/widget/nearby_provider_listview.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

import '../../utils/appp_upgrade_wrapper.dart';


class HomeScreen extends StatefulWidget {
  static Future<void> loadData(bool reload, {int availableServiceCount = 1}) async {
    try {
      await Future.wait([
        Get.find<ServiceController>().getRecommendedSearchList(),
        Get.find<ServiceController>().getAllServiceList(1,reload),
        Get.find<BannerController>().getBannerList(reload),
        Get.find<AdvertisementController>().getAdvertisementList(reload),
        Get.find<CategoryController>().getCategoryList(reload),
        Get.find<ServiceController>().getPopularServiceList(1,reload),
        Get.find<ServiceController>().getTrendingServiceList(1,reload),
        Get.find<ProviderBookingController>().getProviderList(1,reload),
        Get.find<NearbyProviderController>().getProviderList(1,reload),
        Get.find<CampaignController>().getCampaignList(reload),
        Get.find<ServiceController>().getRecommendedServiceList(1, reload),
        Get.find<CheckOutController>().getOfflinePaymentMethod(false, shouldUpdate: false),
        Get.find<ServiceController>().getFeatherCategoryList(reload),
        if(Get.find<AuthController>().isLoggedIn())  Get.find<AuthController>().updateToken(),
        if(Get.find<AuthController>().isLoggedIn())  Get.find<ServiceController>().getRecentlyViewedServiceList(1,reload),
      ]);
      Get.find<BookingDetailsController>().manageDialog();
    } catch (_) {}
  }
  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({super.key, this.addressModel, required this.showServiceNotAvailableDialog}) ;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AddressModel? _previousAddress;
  int availableServiceCount = 0;

  @override
  void initState() {
    super.initState();

    try {
      Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    } catch (_) {}
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<LocationController>().getAddressList();
    }
    if(Get.find<LocationController>().getUserAddress() !=null){
      availableServiceCount = Get.find<LocationController>().getUserAddress()?.availableServiceCountInZone ?? 1;
    }
    HomeScreen.loadData(true, availableServiceCount: availableServiceCount);
    _previousAddress = widget.addressModel;
  }

  homeAppBar({GlobalKey<CustomShakingWidgetState>? signInShakeKey}){
    if(ResponsiveHelper.isDesktop(context)){
      return WebMenuBar(signInShakeKey: signInShakeKey,);
    }else{
      return const AddressAppBar(backButton: false);
    }
  }
  final ScrollController scrollController = ScrollController();
  final signInShakeKey = GlobalKey<CustomShakingWidgetState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: homeAppBar(signInShakeKey: signInShakeKey),
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      body: ResponsiveHelper.isDesktop(context) ? WebHomeScreen(scrollController: scrollController, availableServiceCount: availableServiceCount, signInShakeKey : signInShakeKey,) : SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await HomeScreen.loadData(true, availableServiceCount: 1);
          },
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: GetBuilder<LocationController>(builder: (locationController){
            return GetBuilder<SplashController>(builder: (splashController){
              return GetBuilder<ProviderBookingController>(builder: (providerController){
                return GetBuilder<CategoryController>(builder: (categoryController){
                return GetBuilder<ServiceController>(builder: (serviceController){

                  availableServiceCount = locationController.getUserAddress()?.availableServiceCountInZone ?? availableServiceCount;
                  final hasLoadedServices = serviceController.allService != null || categoryController.categoryList != null;
                  final hasAnyService = (serviceController.allService?.isNotEmpty ?? false) ||
                      (categoryController.categoryList?.isNotEmpty ?? false);
                  final showHomeContent = availableServiceCount > 0 || !hasLoadedServices || hasAnyService;

                  bool isAvailableProvider = providerController.providerList != null && providerController.providerList!.isNotEmpty;
                  int ? providerBooking = splashController.configModel.content?.directProviderBooking;
                  bool isLtr = Get.find<LocalizationController>().isLtr;

                  return ListView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      const HomeSearchBar(),
                      const BannerView(),
                      if (showHomeContent) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: CategoryView(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: HighlightProviderWidget(),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        HorizontalScrollServiceView(fromPage: 'popular_services',serviceList: serviceController.popularServiceList),
                        const RandomCampaignView(),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        RecommendedServiceView(height: isLtr ? 210 : 225,),
                        if (providerBooking == 1 && (isAvailableProvider || providerController.providerList == null)) ...[
                          SizedBox(height: Dimensions.paddingSizeLarge),
                          NearbyProviderListview(height: isLtr ? 190 : 205),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                            child: SizedBox(
                              height: 160,
                              child: ExploreProviderCard(showShimmer: providerController.providerList == null,),
                            ),
                          ),
                        ],
                        if (splashController.configModel.content?.directProviderBooking == 1)
                          const HomeRecommendProvider(height: 220,),
                        if (splashController.configModel.content?.biddingStatus == 1 &&
                            (serviceController.allService?.isNotEmpty ?? false))
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                            child: HomeCreatePostView(showShimmer: false,),
                          ),
                        if (Get.find<AuthController>().isLoggedIn())
                          HorizontalScrollServiceView(fromPage: 'recently_view_services',serviceList: serviceController.recentlyViewServiceList),
                        const CampaignView(),
                        HorizontalScrollServiceView(fromPage: 'trending_services',serviceList: serviceController.trendingServiceList),
                        const FeatheredCategoryView(),
                        if ((serviceController.allService?.isNotEmpty ?? false) &&
                            (ResponsiveHelper.isMobile(context) || ResponsiveHelper.isTab(context)))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 15, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                            child: TitleWidget(
                              textDecoration: TextDecoration.underline,
                              title: 'all_service'.tr,
                              onTap: () => Get.toNamed(RouteHelper.getSearchResultRoute()),
                            ),
                          ),
                        PaginatedListView(
                          scrollController: scrollController,
                          totalSize: serviceController.serviceContent?.total ,
                          offset:  serviceController.serviceContent?.currentPage ,
                          onPaginate: (int offset) async => await serviceController.getAllServiceList(offset, false),
                          showBottomSheet: true,
                          itemView: ServiceViewVertical(
                            service: serviceController.serviceContent != null ? serviceController.allService : null,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                              vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                            ),
                            type: 'others',
                            noDataType: NoDataType.home,
                          ),
                        ),
                      ] else
                        SizedBox(height: MediaQuery.of(context).size.height *.6, child: const ServiceNotAvailableScreen()),
                    ],
                  );
                });
                });
              });
            });
            })
          ),
        ),
      ),
    );
  }
}

