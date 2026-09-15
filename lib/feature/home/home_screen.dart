import 'dart:convert';

import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

import '../../utils/appp_upgrade_wrapper.dart';


class HomeScreen extends StatefulWidget {
  static const String _mumbaiZoneId = 'a0eac7ed-41da-41fa-a119-e9369bba2c99';

  static Future<void> _safeLoad(Future<void> Function() task) async {
    try {
      await task();
    } catch (_) {}
  }

  static String? _cleanZoneId(String? value) {
    if (value == null) {
      return null;
    }
    final zoneId = value.trim();
    if (zoneId.isEmpty || zoneId == 'null' || zoneId == '[]') {
      return null;
    }
    return zoneId;
  }

  static Future<String?> ensureZoneHeader() async {
    AddressModel? address;
    try {
      address = Get.find<LocationController>().getUserAddress();
    } catch (_) {}

    String? zoneId = _cleanZoneId(address?.zoneId);

    if (zoneId == null) {
      try {
        final raw = Get.find<SharedPreferences>().getString(AppConstants.userAddress);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            zoneId = _cleanZoneId(
              (decoded['zone_id'] ?? decoded['zoneId'] ?? decoded['zone_ids'])?.toString(),
            );
            address ??= AddressModel.fromJson(Map<String, dynamic>.from(decoded));
            address.latitude ??= (decoded['lat'] ?? decoded['latitude'])?.toString();
            address.longitude ??= (decoded['lon'] ?? decoded['lng'] ?? decoded['longitude'])?.toString();
          }
        }
      } catch (_) {}
    }

    if (zoneId == null) {
      final lat = address?.latitude;
      final lng = address?.longitude;
      if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
        try {
          final zone = await Get.find<LocationController>().getZone(lat, lng, true, isLoading: true);
          if (zone.isSuccess) {
            zoneId = _cleanZoneId(zone.zoneIds);
            if (zoneId != null && address != null) {
              address.zoneId = zoneId;
              try {
                await Get.find<LocationController>().saveUserAddress(address);
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }

    if (zoneId == null && (address?.address ?? '').toLowerCase().contains('mumbai')) {
      zoneId = _mumbaiZoneId;
    }

    try {
      final prefs = Get.find<SharedPreferences>();
      Get.find<ApiClient>().updateHeader(
        prefs.getString(AppConstants.token),
        zoneId,
        prefs.getString(AppConstants.languageCode),
        prefs.getString(AppConstants.guestId),
      );
    } catch (_) {}

    return zoneId;
  }

  static Future<void> loadData(bool reload, {int availableServiceCount = 1}) async {
    await ensureZoneHeader();
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

  bool _loading = true;
  String? _error;
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<Service> _popular = [];
  List<Service> _services = [];

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
    _loadHome();

    // The visible home content comes from _loadHome(). Everything else is
    // background warm-up for other screens, so let the first frame paint
    // before firing those requests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeScreen.loadData(true, availableServiceCount: availableServiceCount);
    });
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    final map = _asMap(data);
    if (map == null) {
      if (data is List) {
        return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    }

    dynamic list;
    final content = map['content'];
    if (content is Map) {
      list = content['data'] ?? content['services'] ?? content['categories'];
    } else if (content is List) {
      list = content;
    } else {
      list = map['data'];
    }

    if (list is List) {
      return list.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  Future<void> _loadHome() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      await HomeScreen.ensureZoneHeader();
      final api = Get.find<ApiClient>();
      final responses = await Future.wait([
        api.getData('${AppConstants.categoryUrl}&limit=100&offset=1'),
        api.getData('${AppConstants.allServiceUri}?limit=20&offset=1'),
        api.getData('${AppConstants.popularServiceUri}?limit=10&offset=1'),
        api.getData(AppConstants.bannerUri),
      ]);

      final categories = <CategoryModel>[];
      for (final item in _extractList(responses[0].body)) {
        try {
          categories.add(CategoryModel.fromJson(item));
        } catch (_) {}
      }

      final services = <Service>[];
      for (final item in _extractList(responses[1].body)) {
        try {
          services.add(Service.fromJson(item));
        } catch (_) {}
      }

      final popular = <Service>[];
      for (final item in _extractList(responses[2].body)) {
        try {
          popular.add(Service.fromJson(item));
        } catch (_) {}
      }

      final banners = <BannerModel>[];
      for (final item in _extractList(responses[3].body)) {
        try {
          banners.add(BannerModel.fromJson(item));
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _services = services;
        _popular = popular;
        _banners = banners;
        _loading = false;
        if (categories.isEmpty && services.isEmpty && popular.isEmpty) {
          _error = 'Services load nahi ho paayi. Pull to refresh karke try karein.';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Home load nahi ho paayi. Pull to refresh karke try karein.';
      });
    }
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
      backgroundColor: const Color(0xFFF5F6F8),
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
                      onRefresh: _loadHome,
                      child: ListView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 90),
                        children: [
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          if (!_loading && _error != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                              child: Column(
                                children: [
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFF667085)),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _loadHome,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          if (!_loading) ...[
                            _HomeBannerStrip(banners: _banners),
                            _HomeCategoryGrid(categories: _categories),
                            _HomeServiceGrid(title: 'Popular Services', services: _popular),
                            _HomeServiceGrid(title: 'All Services', services: _services),
                          ],
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

class _HomeBannerStrip extends StatelessWidget {
  final List<BannerModel> banners;
  const _HomeBannerStrip({required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                image: banners[index].bannerImageFullPath ?? '',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  const _HomeCategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white,
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
  }
}

class _HomeServiceGrid extends StatelessWidget {
  final String title;
  final List<Service> services;
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
    if (services.isEmpty) {
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
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 210,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
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
