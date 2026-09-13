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
              child: Column(
                children: [
                  const HomeSearchBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => HomeScreen.loadData(true, availableServiceCount: 1),
                      child: ListView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 90),
                        children: const [
                          _HomeBannerSection(),
                          _HomeCategorySection(),
                          _HomePopularSection(),
                          _HomeAllServiceSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HomeBannerSection extends StatelessWidget {
  const _HomeBannerSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<BannerController>()) {
        return const SizedBox.shrink();
      }
      return GetBuilder<BannerController>(builder: (controller) {
        try {
          final banners = controller.banners;
          if (banners == null) {
            return Container(
              height: 150,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }
          if (banners.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 160,
            child: PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final image = banners[index].bannerImageFullPath ?? '';
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImage(image: image, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection();

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<CategoryController>()) {
        return const SizedBox.shrink();
      }
      return GetBuilder<CategoryController>(builder: (controller) {
        try {
          final categories = controller.categoryList;
          if (categories == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          if (categories.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length > 8 ? 8 : categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 96,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      onTap: () {
                        final id = category.id;
                        if (id == null || id.isEmpty) {
                          return;
                        }
                        Get.toNamed(RouteHelper.getCategoryProductRoute(
                          id,
                          category.name ?? '',
                          index.toString(),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 42,
                              width: 42,
                              child: CustomImage(
                                image: category.imageFullPath ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                category.name ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _HomePopularSection extends StatelessWidget {
  const _HomePopularSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<ServiceController>()) {
        return const SizedBox.shrink();
      }
      return GetBuilder<ServiceController>(builder: (controller) {
        try {
          return _HomeServiceGrid(
            title: 'Popular Services',
            services: controller.popularServiceList,
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _HomeAllServiceSection extends StatelessWidget {
  const _HomeAllServiceSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<ServiceController>()) {
        return const SizedBox.shrink();
      }
      return GetBuilder<ServiceController>(builder: (controller) {
        try {
          return _HomeServiceGrid(
            title: 'All Services',
            services: controller.allService,
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _HomeServiceGrid extends StatelessWidget {
  final String title;
  final List<Service>? services;
  const _HomeServiceGrid({required this.title, required this.services});

  String _price(Service service) {
    try {
      num lowest = service.variationsAppFormat?.defaultPrice ?? 0;
      final variations = service.variationsAppFormat?.zoneWiseVariations ?? [];
      for (final variation in variations) {
        final price = variation.price ?? 0;
        if (lowest == 0 || price < lowest) {
          lowest = price;
        }
      }
      if (lowest <= 0) {
        return '';
      }
      return PriceConverter.convertPrice(lowest.toDouble());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (services == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (services!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 210,
            ),
            itemBuilder: (context, index) {
              final service = services![index];
              final price = _price(service);
              return InkWell(
                onTap: () {
                  final id = service.id;
                  if (id == null || id.isEmpty) {
                    return;
                  }
                  Get.toNamed(RouteHelper.getServiceRoute(id));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: CustomImage(
                            image: service.thumbnailFullPath ?? service.coverImageFullPath ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                        child: Text(
                          service.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      if (price.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            price,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
