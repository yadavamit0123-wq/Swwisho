import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

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
      _safeLoad(() => Get.find<BannerController>().getBannerList(reload)),
      _safeLoad(() => Get.find<CategoryController>().getCategoryList(reload)),
      _safeLoad(() => Get.find<ServiceController>().getAllServiceList(1, reload)),
      _safeLoad(() => Get.find<ServiceController>().getPopularServiceList(1, reload)),
      _safeLoad(() => Get.find<ServiceController>().getRecommendedServiceList(1, reload)),
      _safeLoad(() => Get.find<ServiceController>().getTrendingServiceList(1, reload)),
      _safeLoad(() => Get.find<AdvertisementController>().getAdvertisementList(reload)),
      _safeLoad(() => Get.find<CampaignController>().getCampaignList(reload)),
      _safeLoad(() => Get.find<ServiceController>().getFeatherCategoryList(reload)),
      _safeLoad(() => Get.find<ProviderBookingController>().getProviderList(1, reload)),
      _safeLoad(() => Get.find<NearbyProviderController>().getProviderList(1, reload)),
      _safeLoad(() => Get.find<ServiceController>().getRecommendedSearchList()),
      _safeLoad(() => Get.find<CheckOutController>().getOfflinePaymentMethod(false, shouldUpdate: false)),
      if (Get.find<AuthController>().isLoggedIn()) _safeLoad(() => Get.find<AuthController>().updateToken()),
      if (Get.find<AuthController>().isLoggedIn()) _safeLoad(() => Get.find<ServiceController>().getRecentlyViewedServiceList(1, reload)),
    ]);
    try {
      Get.find<BookingDetailsController>().manageDialog();
    } catch (_) {}
  }

  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({super.key, this.addressModel, required this.showServiceNotAvailableDialog});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int availableServiceCount = 1;
  final ScrollController scrollController = ScrollController();
  final signInShakeKey = GlobalKey<CustomShakingWidgetState>();

  @override
  void initState() {
    super.initState();
    try {
      Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    } catch (_) {}
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<LocationController>().getAddressList();
    }
    final savedCount = Get.find<LocationController>().getUserAddress()?.availableServiceCountInZone;
    if (savedCount != null && savedCount > 0) {
      availableServiceCount = savedCount;
    }
    HomeScreen.loadData(true, availableServiceCount: availableServiceCount);
  }

  homeAppBar({GlobalKey<CustomShakingWidgetState>? signInShakeKey}) {
    if (ResponsiveHelper.isDesktop(context)) {
      return WebMenuBar(signInShakeKey: signInShakeKey);
    }
    return const AddressAppBar(backButton: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(signInShakeKey: signInShakeKey),
      endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveHelper.isDesktop(context)
          ? WebHomeScreen(
              scrollController: scrollController,
              availableServiceCount: availableServiceCount,
              signInShakeKey: signInShakeKey,
            )
          : AppUpgradeWrapper(
              child: RefreshIndicator(
                onRefresh: () => HomeScreen.loadData(true, availableServiceCount: 1),
                child: GetBuilder<BannerController>(builder: (_) {
                  return GetBuilder<CategoryController>(builder: (_) {
                    return GetBuilder<ServiceController>(builder: (_) {
                      return CustomScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        slivers: const [
                          SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeSmall)),
                          SliverToBoxAdapter(child: HomeSearchBar()),
                          SliverToBoxAdapter(child: BannerView()),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: CategoryView(),
                            ),
                          ),
                          SliverToBoxAdapter(child: _HomePopularServices()),
                          SliverToBoxAdapter(child: _HomeAllServices()),
                          SliverToBoxAdapter(child: SizedBox(height: 90)),
                        ],
                      );
                    });
                  });
                }),
              ),
            ),
    );
  }
}

class _HomePopularServices extends StatelessWidget {
  const _HomePopularServices();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      return HorizontalScrollServiceView(
        fromPage: 'popular_services',
        serviceList: serviceController.popularServiceList,
      );
    });
  }
}

class _HomeAllServices extends StatelessWidget {
  const _HomeAllServices();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      final services = serviceController.allService;
      if (services != null && services.isEmpty) {
        return const SizedBox.shrink();
      }
      return ServiceViewVertical(
        service: services,
        shimmerLength: 6,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        type: 'others',
        noDataType: NoDataType.home,
      );
    });
  }
}
