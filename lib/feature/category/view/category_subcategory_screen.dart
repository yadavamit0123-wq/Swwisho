import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class CategorySubCategoryScreen extends StatefulWidget {
  final String categoryID;
  final String categoryIndex;
  const CategorySubCategoryScreen({super.key, required this.categoryID, required this.categoryIndex});

  @override
  State<CategorySubCategoryScreen> createState() => _CategorySubCategoryScreenState();
}

class _CategorySubCategoryScreenState extends State<CategorySubCategoryScreen> {
  static final Map<String, List<CategoryModel>> _subCategoryCache = {};
  bool _loading = true;
  String? _error;
  String _selectedCategoryId = '';
  List<CategoryModel> _categories = [];
  List<CategoryModel> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryID;
    _hydrateFromCache();
    _load();
  }

  void _hydrateFromCache() {
    try {
      final cached = Get.find<CategoryController>().categoryList;
      if (cached != null && cached.isNotEmpty) {
        _categories = List<CategoryModel>.from(cached);
      }
    } catch (_) {}
    final cachedSubs = _subCategoryCache[_selectedCategoryId];
    if (cachedSubs != null) {
      _subCategories = List<CategoryModel>.from(cachedSubs);
      _loading = false;
    } else {
      _loading = _categories.isEmpty;
    }
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
        list = content['data'] ?? content['categories'];
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

  Future<void> _load() async {
    if (_categories.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      HomeScreen.ensureZoneHeader();
      final api = Get.find<ApiClient>();
      final categoryResponse = await api.getData('${AppConstants.categoryUrl}&limit=100&offset=1');
      final categories = <CategoryModel>[];
      for (final item in _extractList(categoryResponse.body)) {
        try {
          categories.add(CategoryModel.fromJson(item));
        } catch (_) {}
      }

      if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id ?? '';
      }

      final subCategories = await _fetchSubCategories(_selectedCategoryId);

      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        _subCategories = subCategories;
        _loading = false;
        if (categories.isEmpty && subCategories.isEmpty) {
          _error = 'Categories load nahi ho paayi. Pull to refresh karke try karein.';
        }
      });
      if (_selectedCategoryId.isNotEmpty) {
        _subCategoryCache[_selectedCategoryId] = List<CategoryModel>.from(subCategories);
      }

      try {
        Get.find<CategoryController>().seedCategoryList(categories);
      } catch (_) {}
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Categories load nahi ho paayi. Pull to refresh karke try karein.';
      });
    }
  }

  Future<List<CategoryModel>> _fetchSubCategories(String categoryId) async {
    if (categoryId.isEmpty) {
      return [];
    }
    try {
      final response = await Get.find<ApiClient>().getData('${AppConstants.subCategoryUri}$categoryId');
      final subCategories = <CategoryModel>[];
      for (final item in _extractList(response.body)) {
        try {
          final model = CategoryModel.fromJson(item);
          if (model.isActive != false) {
            subCategories.add(model);
          }
        } catch (_) {}
      }
      return subCategories;
    } catch (_) {
      return [];
    }
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    final id = category.id;
    if (id == null || id.isEmpty || id == _selectedCategoryId) {
      return;
    }
    final cachedSubs = _subCategoryCache[id];
    setState(() {
      _selectedCategoryId = id;
      if (cachedSubs != null) {
        _subCategories = List<CategoryModel>.from(cachedSubs);
        _loading = false;
      } else {
        _loading = true;
      }
    });
    final subCategories = await _fetchSubCategories(id);
    if (!mounted) {
      return;
    }
    _subCategoryCache[id] = List<CategoryModel>.from(subCategories);
    if (_selectedCategoryId != id) {
      return;
    }
    setState(() {
      _subCategories = subCategories;
      _loading = false;
    });
  }

  void _openSubCategory(CategoryModel subCategory) {
    final id = subCategory.id;
    if (id == null || id.isEmpty) {
      return;
    }
    Get.to(() => _SubCategoryServicesScreen(subCategory: subCategory));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('available_service'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: _categories.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected = category.id == _selectedCategoryId;
                        return InkWell(
                          onTap: () => _onCategoryTap(category),
                          child: Container(
                            width: 96,
                            height: 108,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'sub_categories'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
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
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            if (!_loading && _error == null && _subCategories.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Center(child: Text('No sub category found')),
              ),
            if (!_loading)
              ..._subCategories.map((subCategory) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: InkWell(
                    onTap: () => _openSubCategory(subCategory),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 72,
                              width: 72,
                              child: CustomImage(
                                image: subCategory.imageFullPath ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subCategory.name ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                if ((subCategory.description ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subCategory.description ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  '${subCategory.serviceCount ?? 0} ${'services'.tr}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryServicesScreen extends StatefulWidget {
  final CategoryModel subCategory;
  const _SubCategoryServicesScreen({required this.subCategory});

  @override
  State<_SubCategoryServicesScreen> createState() => _SubCategoryServicesScreenState();
}

class _SubCategoryServicesScreenState extends State<_SubCategoryServicesScreen> {
  static final Map<String, List<Service>> _serviceCache = {};
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    final cached = _serviceCache[widget.subCategory.id ?? ''];
    if (cached != null) {
      _services = List<Service>.from(cached);
      _loading = false;
    }
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Service> get _visibleServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _services;
    }
    return _services.where((service) {
      return (service.name ?? '').toLowerCase().contains(query);
    }).toList();
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

  Future<void> _load() async {
    try {
      HomeScreen.ensureZoneHeader();
      final id = widget.subCategory.id ?? '';
      final response = await Get.find<ApiClient>().getData('${AppConstants.serviceBasedOnSubCategory}$id?limit=50&offset=1');
      final services = <Service>[];
      for (final item in _extractList(response.body)) {
        try {
          services.add(Service.fromJson(item));
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      _serviceCache[id] = List<Service>.from(services);
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
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
    final visible = _visibleServices;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(widget.subCategory.name ?? 'services'.tr),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'search_services'.tr,
                suffixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              ),
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : visible.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'No service found'
                              : 'Result not found',
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: visible.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 230,
                        ),
                        itemBuilder: (context, index) {
                          final service = visible[index];
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
                                    RouteHelper.toServiceDetails(id);
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
    );
  }
}

