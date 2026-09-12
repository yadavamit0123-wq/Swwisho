import 'package:demandium/feature/home/widget/nearby_provider_listview.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

import '../../utils/appp_upgrade_wrapper.dart';


class HomeScreen extends StatefulWidget {
  static Future<void> _safeLoad(Future<void> Function() task) async {
    try {
      await task();
    } catch (_) {}
  }

  static void _applySavedZoneHeader() {
    try {
      final address = Get.find<LocationController>().getUserAddress();
      final prefs = Get.find<SharedPreferences>();
      Get.find<ApiClient>().updateHeader(
        prefs.getString(AppConstants.token),
        address?.zoneId,
        prefs.getString(AppConstants.languageCode),
        prefs.getString(AppConstants.guestId),
      );
    } catch (_) {}
  }

  static Future<void> loadData(bool reload, {int availableServiceCount = 1}) async {
    _applySavedZoneHeader();
    await Future.wait([
      _safeLoad(() => Get.find<ServiceController>().getRecommendedSearchList()),
      _safeLoad(() => Get.find<ServiceController>().getAllServiceList(1,reload)),
      _safeLoad(() => Get.find<BannerController>().getBannerList(reload)),
      _safeLoad(() => Get.find<AdvertisementController>().getAdvertisementList(reload)),
      _safeLoad(() => Get.find<CategoryController>().getCategoryList(reload)),
      _safeLoad(() => Get.find<ServiceController>().getPopularServiceList(1,reload)),
      _safeLoad(() => Get.find<ServiceController>().getTrendingServiceList(1,reload)),
      _safeLoad(() => Get.find<ProviderBookingController>().getProviderList(1,reload)),
      _safeLoad(() => Get.find<NearbyProviderController>().getProviderList(1,reload)),
      _safeLoad(() => Get.find<CampaignController>().getCampaignList(reload)),
      _safeLoad(() => Get.find<ServiceController>().getRecommendedServiceList(1, reload)),
      _safeLoad(() => Get.find<CheckOutController>().getOfflinePaymentMethod(false, shouldUpdate: false)),
      _safeLoad(() => Get.find<ServiceController>().getFeatherCategoryList(reload)),
      if(Get.find<AuthController>().isLoggedIn()) _safeLoad(() => Get.find<AuthController>().updateToken()),
      if(Get.find<AuthController>().isLoggedIn()) _safeLoad(() => Get.find<ServiceController>().getRecentlyViewedServiceList(1,reload)),
    ]);
    try {
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
    if (availableServiceCount <= 0) {
      availableServiceCount = 1;
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

                  final zoneCount = locationController.getUserAddress()?.availableServiceCountInZone;
                  if (zoneCount != null && zoneCount > 0) {
                    availableServiceCount = zoneCount;
                  } else if (availableServiceCount <= 0) {
                    availableServiceCount = 1;
                  }
                  const showHomeContent = true;

                  bool isAvailableProvider = providerController.providerList != null && providerController.providerList!.isNotEmpty;
                  int? providerBooking;
                  int? biddingStatus;
                  try {
                    providerBooking = splashController.configModel.content?.directProviderBooking;
                    biddingStatus = splashController.configModel.content?.biddingStatus;
                  } catch (_) {}
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
                        if (providerBooking == 1)
                          const HomeRecommendProvider(height: 220,),
                        if (biddingStatus == 1 &&
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

