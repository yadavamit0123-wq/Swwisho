import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  bool _loading = true;
  String? _error;
  List<Service> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is String && data.isNotEmpty) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is List) {
      return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (data is Map) {
      final content = data['content'];
      dynamic list;
      if (content is Map) {
        list = content['data'] ?? content['services'];
      } else if (content is List) {
        list = content;
      } else {
        list = data['data'];
      }
      if (list is List) {
        return list.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
    return [];
  }

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

  Future<void> _loadOffers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await HomeScreen.ensureZoneHeader();
      final response = await Get.find<ApiClient>().getData('${AppConstants.offerListUri}?limit=50&offset=1');
      final offers = <Service>[];
      for (final item in _extractList(response.body)) {
        try {
          offers.add(Service.fromJson(item));
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _offers = offers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Offers load nahi ho paayi. Pull to refresh karke try karein.';
      });
    }
  }

  void _openAddToCart(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceCenterDialog(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('offers'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOffers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Container(
              height: 90,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'current_offers'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!_loading && _error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(onPressed: _loadOffers, child: const Text('Retry')),
                  ],
                ),
              ),
            if (!_loading && _error == null && _offers.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Center(child: Text('No offer found')),
              ),
            if (!_loading && _offers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _offers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 230,
                  ),
                  itemBuilder: (context, index) {
                    final service = _offers[index];
                    final price = _price(service);
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              final id = service.id;
                              if (id == null || id.isEmpty) {
                                return;
                              }
                              Get.toNamed(RouteHelper.getServiceRoute(id));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: SizedBox(
                                    height: 110,
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
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () => _openAddToCart(service),
                              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
